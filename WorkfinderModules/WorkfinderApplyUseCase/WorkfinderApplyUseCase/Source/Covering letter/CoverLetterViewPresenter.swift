
import Foundation
import WorkfinderCommon

public protocol CoverLetterViewPresenterProtocol {
    var view: CoverLetterViewProtocol? { get set }
    var nextButtonIsEnabled: Bool { get }
    var displayString: String { get }
    var attributedDisplayString: NSAttributedString { get }
    func onViewDidLoad(view: CoverLetterViewProtocol)
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
    let allPickListsDictionary: PicklistsDictionary
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
        displayString = renderer.renderToPlainString(with: [:])
        attributedDisplayString = renderer.renderToAttributedString(with: [:])
        view?.refresh(from: self)
    }
    
    func onDidTapShowCoverLetterButton() {
        updateLetterDisplayStrings()
        displayString = _letterDisplayString
        attributedDisplayString = _attributedDisplayString
        view?.refresh(from: self)
    }
    
    func updateLetterDisplayStrings() {
        guard let renderer = renderer else { return }
        var fieldValues = [String: String]()
        allPickListsDictionary.forEach { (keyValue) in
            let (_, picklist) = keyValue
            let items = picklist.selectedItems.map { (picklistIem) -> String in
                return picklistIem.value ?? "unnamed value"
            }
            if !items.isEmpty {
                fieldValues[picklist.title] = Grammar().commaSeparatedList(strings: items)
            }
        }
        _letterDisplayString = renderer.renderToPlainString(with: fieldValues)
        _attributedDisplayString = renderer.renderToAttributedString(with: fieldValues)
    }
    
    func onDidTapSelectOptionsButton() {
        coordinator?.onDidTapSelectOptions(referencedPicklists: picklistsReferencedByTemplate(), completion: { [weak self] picklistsDictionary in
            guard let self = self else { return }
            self.updateLetterDisplayStrings()
            self.view?.refresh(from: self)
        })
    }
    
    func picklistsReferencedByTemplate() -> PicklistsDictionary {
        return allPickListsDictionary.filter { (element) -> Bool in
            let picklist = element.value
            return embeddedFieldNames.contains(picklist.title)
        }
    }
    
    func onDidDismiss() { coordinator?.onCoverLetterDidDismiss() }
    
    func onViewDidLoad(view: CoverLetterViewProtocol) {
        self.view = view
        view.refresh(from: self)
        view.showLoadingIndicator()
        templateProvider.fetchCoverLetterTemplateListJson() { [weak self] (result) in
            self?.view?.hideLoadingIndicator()
            switch result {
            case .success(let templateListJson):
                self?.onTemplateListFetched(templateListJson: templateListJson)
            case .failure(let error):
                print("Error fetching template: \(error)")
            }
        }
    }
    
    func onTemplateListFetched(templateListJson: TemplateListJson) {
        self.templateModel = templateListJson.results.first ?? defaultTemplate
        let parser = TemplateParser(templateModel: templateModel)
        embeddedFieldNames = parser.allFieldNames()
        renderer = TemplateRenderer(parser: parser)
    }
    
    init(coordinator: CoverletterCoordinatorProtocol?,
         templateProvider: TemplateProviderProtocol,
         allPicklistsDictionary: PicklistsDictionary) {
        self.coordinator = coordinator
        self.templateModel = defaultTemplate
        self.templateProvider = templateProvider
        self.allPickListsDictionary = allPicklistsDictionary
    }
    
    private let defaultTemplate = TemplateModel(uuid: "", templateString:
    """
    Dear Sir/Madam

    Oh dear, the server failed to return any templates again! But I am a clever iPhone so I can just make one up!

    {{motivation}}
    I would like to apply for the {{role}} role at your company.
    I wish to acquire the following skills: {{skills}}.
    I consider myself to have the following personal attributes: {{attributes}}.
    I am in year {{year}} of study at {{educational institution}}.
    I will be available between {{availability}}
    My experience is:
    {{experience}}
    """)
}
