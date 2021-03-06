
import Foundation
import WorkfinderCommon
import WorkfinderServices

class CoverLetterLogic {
    let flowType: CoverLetterFlowType
    var defaultTemplate = TemplateModel(uuid: "empty", templateString: "", isProject: false, minimumAge: 13)
    lazy var templateModel: TemplateModel = self.defaultTemplate
    let picklistsStore: PicklistsStoreProtocol
    var letterDisplayString = ""
    var attributedDisplayString = NSAttributedString()
    var renderer: TemplateRenderer?
    let fixedFieldValues: [String:String?]
    var embeddedFieldNames = [String]()
    var templateService: TemplateProviderProtocol
    var candidateService: FetchCandidateServiceProtocol
    var isLetterComplete: Bool { renderer?.isComplete ?? false }
    var shouldHideAnsweredQuestions: Bool = true
    var candidate = UserRepository().loadCandidate()
    
    lazy var allPicklistsDictionary: PicklistsDictionary = {
        let picklists = picklistsStore.load()
        nullifyOutofDateAvailability(picklists: picklists)
        nullifyOutMotivationAndExperience(picklists: picklists)
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
         candidateService: FetchCandidateServiceProtocol,
         companyName: String,
         hostName: String,
         candidateName: String?,
         projectTitle: String?,
         flowType: CoverLetterFlowType
         ) {
        self.flowType = flowType
        self.picklistsStore = picklistsStore
        self.templateService = templateService
        self.candidateService = candidateService
        self.fixedFieldValues = [
            "host": hostName,
            "company" : companyName,
            "candidate": candidateName,
            "project title": projectTitle
        ]
    }
    
    func load(completion: @escaping (Error?) -> Void) {
        guard let candidateUuid = candidate.uuid else {
            loadTemplates(completion: completion)
            completion(nil)
            return
        }
        candidateService.fetchCandidate(uuid: candidateUuid) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let candidate):
                UserRepository().saveCandidate(candidate)
                let strongestSkillsPicklist = self.allPicklistsDictionary[.strongestSkills]
                strongestSkillsPicklist?.preselectedUuids = Array((self.candidate.strongestSkills ?? []).prefix(3))
                strongestSkillsPicklist?.fetchItems(completion: { _ , result in
                    switch result {
                    case .success(_):
                        let attributesPicklist = self.allPicklistsDictionary[.attributes]
                        attributesPicklist?.preselectedUuids = Array((self.candidate.personalAttributes ?? []).prefix(3))
                        attributesPicklist?.fetchItems(completion: { _, result in
                            switch result {
                            case .success(_):
                                self.loadTemplates(completion: completion)
                            case .failure(let error):
                                completion(error)
                            }
                        })
                    case .failure(let error):
                        completion(error)
                    }
                })
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    private func loadTemplates(completion: @escaping (Error?) -> Void) {
        templateService.fetchCoverLetterTemplateListJson() { [weak self] (result) in
            switch result {
            case .success(let templates):
                self?.onTemplateListFetched(templates: templates)
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func onTemplateListFetched(templates: [TemplateModel]) {
        let templateModel = templates.first ?? defaultTemplate
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
    
    func allPicklists() -> [PicklistProtocol] {
        var first = sortedCoverLetterPicklists()
        first.append(contentsOf: additionalInformationPicklists())
        return first
    }
    
    func picklistHavingTitle(title: String) -> PicklistProtocol? {
        return allPicklists().first { (picklist) -> Bool in picklist.type.title == title }
    }
    
    func sortedCoverLetterPicklists() -> [PicklistProtocol] {
        ([PicklistProtocol](picklistsReferencedByTemplate().values)).sorted(by: { (p1, p2) -> Bool in
            p1.type.rawValue < p2.type.rawValue
        })
    }
    
    func nonOptionalSortedCoverLetterPicklists() -> [PicklistProtocol] {
        sortedCoverLetterPicklists().filter { (picklist) -> Bool in
            shouldShowPicklist(picklist)
        }
    }
    
    func shouldShowPicklist(_ picklist: PicklistProtocol) -> Bool {
        if !picklist.type.isPresentationOptionalWhenPopulated { return true }
        if !picklist.isPopulated { return true }
        if !shouldHideAnsweredQuestions { return true }
        return false
    }
    
    func additionalInformationPicklists() -> [PicklistProtocol] {
        let skillsPicklist = allPicklistsDictionary[.strongestSkills]
        let attributesPicklist = allPicklistsDictionary[.attributes]
        let skillsAreIncludedInLetter: Bool = picklistsReferencedByTemplate()[.strongestSkills] != nil
        let attributesAreIncludedInLetter: Bool = picklistsReferencedByTemplate()[.attributes] != nil
        var additionalPicklists = PicklistsDictionary()
        if !skillsAreIncludedInLetter { additionalPicklists[.strongestSkills] = skillsPicklist }
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
            let startDate = Date.workfinderDateStringToDate(availabilityStart)?.startOfDay,
            let endDate = Date.workfinderDateStringToDate(availabilityEnd)?.endOfDay,
            let durationPicklist = picklists.first(where: { (picklist) -> Bool in
                picklist.type == .duration
            }),
            let duration = durationPicklist.selectedItems.first,
            let minimumDuration = duration.range?.lower
            else { return nil }
        
        let availabilityInterval = endDate.timeIntervalSince(startDate)
        let durationInterval: Double
        let secondsPerWeek = 7.0 * 24.0 * 3600.0
        if let maximumDuration = duration.range?.upper {
            durationInterval = Double(maximumDuration - minimumDuration) * secondsPerWeek
        } else {
            durationInterval = Double(minimumDuration) * secondsPerWeek
        }
        
        if durationInterval > availabilityInterval + 1 {
            durationPicklist.deselectAll()
            return WorkfinderError(errorType: .custom(title: "Inconsistent duration and availability", description: "Please choose a duration that fits within your availability"), attempting: "Consistency check")
        }
        return nil
    }
    
    func nullifyOutMotivationAndExperience(picklists: PicklistsDictionary) {
        picklists[.motivation]?.deselectAll()
        picklists[.experience]?.deselectAll()
    }
    
    func nullifyOutofDateAvailability(picklists: PicklistsDictionary) {
        let now = Date()
        let yearLater = now.addingTimeInterval(TimeInterval(360*24*3600))
        guard
            let availabilityPicklist = picklists[.availabilityPeriod],
            let availabilityStartItem = availabilityPicklist.selectedItems.first,
            let startDateString = availabilityStartItem.value,
            let startDate = Date.workfinderDateStringToDate(startDateString)
            else { return }
        if startDate.startOfDay < now.startOfDay || startDate.isGreaterThanDate(dateToCompare: yearLater) {
            availabilityPicklist.deselectAll()
            return
        }

        if availabilityPicklist.selectedItems.count == 2 {
            let availabilityEndItem = availabilityPicklist.selectedItems[1]
            let endDateString = availabilityEndItem.value!
            let endDate = Date.workfinderDateStringToDate(endDateString)!
            if endDate.isLessThanDate(dateToCompare: startDate) || endDate.isGreaterThanDate(dateToCompare: yearLater) {
                availabilityPicklist.deselectAll()
            }
        }

    }
}
