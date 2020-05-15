
import Foundation
import WorkfinderCommon

public protocol CoverLetterViewPresenterProtocol {
    var view: CoverLetterViewProtocol? { get set }
    var nextButtonIsEnabled: Bool { get }
    var displayString: String { get }
    var attributedDisplayString: NSAttributedString { get }
    func onViewDidLoad(view: CoverLetterViewProtocol)
    func loadData(completion: @escaping (Error?) -> Void)
    func onDidTapShowTemplateButton()
    func onDidTapShowCoverLetterButton()
    func onDidTapSelectOptionsButton()
    func onDidDismiss()
    func onDidTapNext()
}

class CoverLetterViewPresenter: CoverLetterViewPresenterProtocol {
    
    var coordinator: CoverletterCoordinatorProtocol?
    var view: CoverLetterViewProtocol?
    var displayString: String = ""
    var attributedDisplayString = NSAttributedString()
    var renderer: TemplateRendererProtocol?
    let templateProvider: TemplateProviderProtocol
    let picklistsStore: PicklistsStoreProtocol
    var allPickListsDictionary: PicklistsDictionary
    var isShowingTemplate: Bool = false
    var nextButtonIsEnabled: Bool { return renderer?.isComplete ?? false }
    var templateModel: TemplateModel
    var embeddedFieldNames = [String]()
    private var _letterDisplayString = ""
    private var _attributedDisplayString = NSAttributedString()
    
    func onDidTapNext() {
        coordinator?.onDidCompleteCoverLetter()
    }
    
    func onDidTapShowTemplateButton() {
        guard let renderer = renderer else { return }
        displayString = renderer.renderToPlainString(with: fixedFieldValues)
        attributedDisplayString = renderer.renderToAttributedString(with: fixedFieldValues)
        view?.refreshFromPresenter()
    }
    
    func onDidTapShowCoverLetterButton() {
        updateLetterDisplayStrings()
        displayString = _letterDisplayString
        attributedDisplayString = _attributedDisplayString
        view?.refreshFromPresenter()
    }
    
    let fixedFieldValues: [String:String?]
    
    func updateLetterDisplayStrings() {
        guard let renderer = renderer else { return }
        var fieldValues = [String: String]()
        allPickListsDictionary.forEach { (keyValue) in
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
                    if picklistIem.isOther {
                        return picklistIem.otherValue ?? ""
                    } else {
                        return picklistIem.value ?? (picklistIem.name ?? "unnamed value")
                    }
                }
            }
            if !items.isEmpty {
                if picklist.type == .availabilityPeriod {
                    fieldValues[picklist.type.title] = "\(items[0]) to \(items[1])"
                } else {
                    fieldValues[picklist.type.title] = Grammar().commaSeparatedList(strings: items)
                }
            }
        }
        let fieldAndFixedFields = addStandardFieldValues(fieldValues: fieldValues)
        _letterDisplayString = renderer.renderToPlainString(with: fieldAndFixedFields)
        _attributedDisplayString = renderer.renderToAttributedString(with: fieldAndFixedFields)
    }
    
    func addStandardFieldValues(fieldValues: [String: String?]) -> [String: String?] {
        var updatedFields = fieldValues
        fixedFieldValues.forEach { (field) in
            updatedFields[field.key] = field.value
        }
        return updatedFields
    }
    
    func onDidTapSelectOptionsButton() {
        coordinator?.onDidTapSelectOptions(referencedPicklists: picklistsReferencedByTemplate(), completion: { [weak self] picklistsDictionary in
            guard let self = self else { return }
            self.picklistsStore.save()
            self.updateLetterDisplayStrings()
            self.view?.refreshFromPresenter()
        })
    }
    
    func picklistsReferencedByTemplate() -> PicklistsDictionary {
        return allPickListsDictionary.filter { (element) -> Bool in
            let picklist = element.value
            return embeddedFieldNames.contains(picklist.type.title)
        }
    }
    
    func onDidDismiss() { coordinator?.onCoverLetterDidDismiss() }
    
    func onViewDidLoad(view: CoverLetterViewProtocol) {
        self.view = view
        self.allPickListsDictionary = loadPicklists()
        view.refreshFromPresenter()
    }
    
    func loadData(completion: @escaping (Error?) -> Void) {
        templateProvider.fetchCoverLetterTemplateListJson() { [weak self] (result) in
            switch result {
            case .success(let templateListJson):
                self?.onTemplateListFetched(templateListJson: templateListJson)
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func loadPicklists() -> PicklistsDictionary {
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
        if startDate < Date() {
            availabilityPicklist.deselectAll()
        }
    }
    
    func onTemplateListFetched(templateListJson: TemplateListJson) {
        self.templateModel = templateListJson.results.first ?? CoverLetterViewPresenter.defaultTemplate
        let parser = TemplateParser(templateModel: templateModel)
        embeddedFieldNames = parser.allFieldNames()
        renderer = TemplateRenderer(parser: parser)
    }
    
    init(coordinator: CoverletterCoordinatorProtocol?,
         templateProvider: TemplateProviderProtocol,
         picklistsStore: PicklistsStoreProtocol,
         companyName: String,
         hostName: String,
         candidateName: String?) {
        self.coordinator = coordinator
        self.templateModel = CoverLetterViewPresenter.defaultTemplate
        self.templateProvider = templateProvider
        self.picklistsStore = picklistsStore
        self.allPickListsDictionary = [:]
        self.fixedFieldValues = [
            "host": hostName,
            "company" : companyName,
            "candidate": candidateName
        ]
    }
    
    private static var defaultTemplate: TemplateModel {
        let template = PicklistType.allCases.reduce("") { (result, picklistType) -> String in
            return "\(result)\n\(picklistType.title): {{\(picklistType.title)}}"
        }
        return TemplateModel(uuid: "", templateString:template)
    }
   
}
