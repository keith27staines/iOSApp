
import Foundation
import WorkfinderCommon

class CoverLetterViewPresenter: CoverLetterViewPresenterProtocol {
    let log: F4SAnalytics
    var coordinator: CoverletterCoordinatorProtocol?
    let logic: CoverLetterLogic
    var view: CoverLetterViewProtocol?
    var displayString: String { logic.letterDisplayString }
    var attributedDisplayString: NSAttributedString { logic.attributedDisplayString }
    var isShowingTemplate: Bool = false
    var isLetterComplete: Bool { logic.isLetterComplete }
    let primaryButtonTitle: String
    
    func onDidTapPrimaryButton() {
        coordinator?.onCoverLetterTapPrimaryButton()
    }
    
    func onDidCancel() { coordinator?.onCoverLetterDismiss() }
    
    func onDidTapShowQuestionsList() {
        coordinator?.onCoverLetterTapEdit()
    }
    
    func onDidTapField(name: String) {
        coordinator?.onCoverLetterTapField(name: name)
    }
    
    func onViewDidAppear() {
        log.track(TrackingEvent.event(type: .letterPreview, flow: logic.flowType))
    }
    
    func onViewDidLoad(view: CoverLetterViewProtocol) {
        self.view = view
        logic.updateLetterDisplayStrings()
        view.refreshFromPresenter()
    }
    
    func loadData(completion: @escaping (Error?) -> Void) {
        logic.load(completion: completion)
    }
    
    init(coordinator: CoverletterCoordinatorProtocol?,
         primaryButtonTitle: String,
         logic: CoverLetterLogic,
         log: F4SAnalytics) {
        self.logic = logic
        self.coordinator = coordinator
        self.primaryButtonTitle = primaryButtonTitle
        self.log = log
    }
}


