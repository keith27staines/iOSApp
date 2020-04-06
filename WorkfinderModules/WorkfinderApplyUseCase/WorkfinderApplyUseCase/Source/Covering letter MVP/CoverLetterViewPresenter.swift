
import Foundation

public protocol CoverLetterViewPresenterProtocol {
    var view: CoverLetterViewProtocol? { get set }
    var displayString: String { get }
    var attributedDisplayString: NSAttributedString { get }
    func onViewDidLoad(view: CoverLetterViewProtocol)
    func onDidTapShowTemplateButton()
    func onDidTapShowCoverLetterButton()
    func onDidTapSelectOptionsButton()
    func onDidDismiss()
}

class CoverLetterViewPresenter: CoverLetterViewPresenterProtocol {
    var coordinator: CoverletterCoordinatorProtocol?
    var view: CoverLetterViewProtocol?
    var displayString: String = ""
    var attributedDisplayString = NSAttributedString()
    var renderer: TemplateRendererProtocol?
    let templateProvider: TemplateProviderProtocol
    
    var pickListsDictionary = PicklistsDictionary()
     
    var isShowingTemplate: Bool = false
    
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
    
    private var _letterDisplayString = ""
    private var _attributedDisplayString = NSAttributedString()
    
    func updateLetterDisplayStrings() {
        guard let renderer = renderer else { return }
        var fieldValues = [String: String]()
        pickListsDictionary.forEach { (keyValue) in
            let (_, picklist) = keyValue
            let items = picklist.selectedItems.map { (picklistIem) -> String in
                return picklistIem.value ?? "unnamed value"
            }
            if !picklist.selectedItems.isEmpty {
                fieldValues[picklist.title] = Grammar().commaSeparatedList(strings: items)
            } else {
                fieldValues[picklist.title] = Grammar().commaSeparatedList(strings: ["item1","item2","item3"])
            }
        }
        _letterDisplayString = renderer.renderToPlainString(with: fieldValues)
        _attributedDisplayString = renderer.renderToAttributedString(with: fieldValues)
    }
    
    func onDidTapSelectOptionsButton() {
        coordinator?.onDidTapSelectOptions(completion: { [weak self] picklistsDictionary in
            guard let self = self else { return }
            self.pickListsDictionary = picklistsDictionary
            self.updateLetterDisplayStrings()
            self.view?.refresh(from: self)
        })
    }
    
    func onDidDismiss() { coordinator?.onCoverLetterDidDismiss() }
    
    func onViewDidLoad(view: CoverLetterViewProtocol) {
        self.view = view
        view.refresh(from: self)
        view.showLoadingIndicator()
        templateProvider.fetchCoverLetterTemplate(dateOfBirth: Date()) { [weak self] (result) in
            self?.view?.hideLoadingIndicator()
            switch result {
            case .success(let templateModel):
                self?.onTemplateFetched(templateModel: templateModel)
            case .failure(let error):
                print("Error fetching template: \(error)")
            }
        }
    }
    
    func onTemplateFetched(templateModel: TemplateModel) {
        let parser = TemplateParser(templateModel: templateModel)
        renderer = TemplateRenderer(parser: parser)
    }
    
    init(coordinator: CoverletterCoordinatorProtocol?,
         templateProvider: TemplateProviderProtocol) {
        self.coordinator = coordinator
        self.templateProvider = templateProvider
    }
}
