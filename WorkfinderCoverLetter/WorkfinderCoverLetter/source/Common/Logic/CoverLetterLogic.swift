
import Foundation
import WorkfinderCommon
import WorkfinderServices

class CoverLetterLogic {
    let flowType: CoverLetterFlowType
    var defaultTemplate = TemplateModel(uuid: "empty", templateString: "")
    lazy var templateModel: TemplateModel = self.defaultTemplate
    let picklistsStore: PicklistsStoreProtocol
    var letterDisplayString = ""
    var attributedDisplayString = NSAttributedString()
    var renderer: TemplateRenderer?
    let fixedFieldValues: [String:String?]
    var embeddedFieldNames = [String]()
    var templateService: TemplateProviderProtocol
    
    var isLetterComplete: Bool { renderer?.isComplete ?? false }
    
    lazy var allPicklistsDictionary: PicklistsDictionary = {
        let picklists = picklistsStore.load()
        nullifyOutofDateAvailability(picklists: picklists)
        return picklists
    }()
    
    func picklistsDidUpdate() {
        save()
        updateLetterDisplayStrings()
    }
    
    func save() {
        picklistsStore.save()
    }
    
    init(picklistsStore: PicklistsStoreProtocol,
         templateService: TemplateProviderProtocol,
         companyName: String,
         hostName: String,
         candidateName: String?,
         projectTitle: String?,
         flowType: CoverLetterFlowType
         ) {
        self.flowType = flowType
        self.picklistsStore = picklistsStore
        self.templateService = templateService
        self.fixedFieldValues = [
            "host": hostName,
            "company" : companyName,
            "candidate": candidateName,
            "project title": projectTitle
        ]
    }
    
    func load(completion: @escaping (Error?) -> Void) {
        templateService.fetchCoverLetterTemplateListJson() { [weak self] (result) in
            switch result {
            case .success(let templateListJson):
                self?.onTemplateListFetched(templateListJson: templateListJson)
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func onTemplateListFetched(templateListJson: TemplateListJson) {
        let templateModel = templateListJson.results.first ?? defaultTemplate
        let preprocessor = TemplateModelPreprocessor()
        self.templateModel = preprocessor.preprocess(templateModel: templateModel)
        let parser = TemplateParser(templateModel: self.templateModel)
        embeddedFieldNames = parser.allFieldNames()
        renderer = TemplateRenderer(parser: parser)
        updateLetterDisplayStrings()
    }
    
    func updateLetterDisplayStrings() {
        guard let renderer = renderer else { return }
        var fieldValues = [String: String]()
        allPicklistsDictionary.forEach { (keyValue) in
            let (_, picklist) = keyValue
            let items = picklist.selectedItems.map { (picklistIem) -> String in
                if picklistIem.isDateString == true {
                    if let date = Date.workfinderDateStringToDate(picklistIem.value ?? "") {
                        let df = DateFormatter()
                        df.timeStyle = .none
                        df.dateStyle = .long
                        return df.string(from: date)
                    } else {
                        return picklistIem.value ?? (picklistIem.name ?? "unnamed value")
                    }
                } else {
                    var returnValue: String
                    if picklistIem.isOther {
                        returnValue = picklistIem.otherValue ?? ""
                    } else {
                        returnValue = (picklistIem.value ?? (picklistIem.name ?? "unnamed value"))
                    }
                    return picklist.type.presentationValueShouldBeLowercased ? returnValue.lowercased() : returnValue
                }
            }
            if !items.isEmpty {
                if picklist.type == .availabilityPeriod {
                    fieldValues[picklist.type.title] = "\(items[0])"
                    if items.count == 2 {
                        fieldValues[picklist.type.title] = "\(items[0]) to \(items[1])"
                    }
                } else {
                    fieldValues[picklist.type.title] = Grammar().commaSeparatedList(strings: items)
                }
            }
        }
        let fieldAndFixedFields = addStandardFieldValues(fieldValues: fieldValues)
        letterDisplayString = renderer.renderToPlainString(with: fieldAndFixedFields)
        attributedDisplayString = renderer.renderToAttributedString(with: fieldAndFixedFields)
    }
    
    func addStandardFieldValues(fieldValues: [String: String?]) -> [String: String?] {
        var updatedFields = fieldValues
        fixedFieldValues.forEach { (field) in
            updatedFields[field.key] = field.value
        }
        return updatedFields
    }
    
    func picklistsReferencedByTemplate() -> PicklistsDictionary {
        return allPicklistsDictionary.filter { (element) -> Bool in
            let picklist = element.value
            return embeddedFieldNames.contains(picklist.type.title)
        }
    }
    
    func sortedCoverLetterPicklists() -> [PicklistProtocol] {
        ([PicklistProtocol](picklistsReferencedByTemplate().values)).sorted(by: { (p1, p2) -> Bool in
            p1.type.rawValue < p2.type.rawValue
        })
    }
    
    func nonOptionalSortedCoverLetterPicklists() -> [PicklistProtocol] {
        sortedCoverLetterPicklists().filter { (picklist) -> Bool in
            !(picklist.type.isPresentationOptionalWhenPopulated && picklist.isPopulated)
        }
    }
    
    func additionalInformationPicklists() -> [PicklistProtocol] {
        let skillsPicklist = allPicklistsDictionary[.skills]
        let attributesPicklist = allPicklistsDictionary[.attributes]
        let skillsAreIncludedInLetter: Bool = picklistsReferencedByTemplate()[.skills] != nil
        let attributesAreIncludedInLetter: Bool = picklistsReferencedByTemplate()[.attributes] != nil
        var additionalPicklists = PicklistsDictionary()
        if !skillsAreIncludedInLetter { additionalPicklists[.skills] = skillsPicklist }
        if !attributesAreIncludedInLetter { additionalPicklists[.attributes] = attributesPicklist }
        return ([PicklistProtocol](additionalPicklists.values)).sorted(by: { (p1, p2) -> Bool in
            p1.type.rawValue < p2.type.rawValue
        })
    }
    
    func consistencyCheck() -> WorkfinderError? {
        let picklists = sortedCoverLetterPicklists()
        guard
            let availabilityPicklist = picklists.first(where: { (picklist) -> Bool in
                picklist.type == .availabilityPeriod
            }),
            let availabilityStart = availabilityPicklist.selectedItems.first?.value,
            let availabilityEnd = availabilityPicklist.selectedItems.last?.value,
            let durationPicklist = picklists.first(where: { (picklist) -> Bool in
                picklist.type == .duration
            }),
            let duration = durationPicklist.selectedItems.first,
            let lowerDuration = duration.range?.lower,
            let upperDuration = duration.range?.upper,
            let startDate = Date.workfinderDateStringToDate(availabilityStart)?.startOfDay,
            let endDate = Date.workfinderDateStringToDate(availabilityEnd)?.endOfDay
            else { return nil }
        
        let availabilityInterval = endDate.timeIntervalSince(startDate)
        let durationInterval = Double(upperDuration - lowerDuration) * 7.0 * 24.0 * 3600.0
        if durationInterval > availabilityInterval + 1 {
            return WorkfinderError(errorType: .custom(title: "Inconsistent duration and availability", description: "Please choose a duration that fits within your availability"), attempting: "Consistency check")
            durationPicklist.deselectAll()
        }
        return nil
    }
    
    private func loadPicklists() -> PicklistsDictionary {
        let picklists = picklistsStore.load()
        nullifyOutofDateAvailability(picklists: picklists)
        return picklists
    }
    
    func nullifyOutofDateAvailability(picklists: PicklistsDictionary) {
        guard
            let availabilityPicklist = picklists[.availabilityPeriod],
            let availabilityItem = availabilityPicklist.selectedItems.first,
            let startDateString = availabilityItem.value,
            let startDate = Date.workfinderDateStringToDate(startDateString)
            else { return }
        if startDate.startOfDay < Date().startOfDay {
            availabilityPicklist.deselectAll()
        }
    }
}