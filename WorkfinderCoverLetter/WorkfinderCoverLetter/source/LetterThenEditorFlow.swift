
import WorkfinderCommon
import WorkfinderUI
import WorkfinderCoordinators

public class LetterThenEditorFlow: CoverLetterFlow  {
    
    public override var messageHandler: UserMessageHandler? { coverLetterViewController?.messageHandler }
    
    lazy var presenter: CoverLetterViewPresenterProtocol = {
        let presenter = CoverLetterViewPresenter(
            coordinator: self,
            primaryButtonTitle: self.applyCoordinator?.coverLetterPrimaryButtonText ?? "Next",
            logic: logic,
            log: self.injected.log
        )
        return presenter
    }()
    
    override public func start() {
        super.start()
        let viewController = CoverLetterViewController(presenter: presenter)
        self.coverLetterViewController = viewController
        navigationRouter.push(viewController: viewController, animated: true)
    }
    
    override func onCoverLetterTapPrimaryButton() {
        finishWorkflow(cancelled: false)
    }
    
    override func onCoverLetterTapEdit() {
        let presenter = LetterEditorPresenter(coordinator: self, logic: logic, log: self.injected.log)
        let vc = LetterEditorViewController(presenter: presenter)
        letterEditorViewController = vc
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    override func onCoverLetterTapField(name: String, completion: @escaping (Error?) -> Void) {
        guard let picklist = logic.picklistHavingTitle(title: name)
        else {
            let error = WorkfinderError(title: "Not editable", description: "The \"\(name)\" field cannot be edited", canRetry: false)
            completion(error)
            return
        }
        if picklist.isLoaded {
            showPicklist(picklist, completion: completion)
            completion(nil)
            return
        }
        (picklist as? Picklist)?.fetchItems(completion: { [weak self] (_, result) in
            switch result {
            case .success(_):
                self?.showPicklist(picklist, completion: completion)
            case .failure(let error):
                completion(error)
            }
        })
    }

    override func onCoverLetterDismiss() {
        finishWorkflow(cancelled: true)
    }
    
    override func onLetterEditorTapPrimaryButton() {
        onLetterEditorDismiss()
        navigationRouter.pop(animated: true)
    }
    
    override func onLetterEditorDismiss() {
        logic.save()
        self.coverLetterViewController?.messageHandler.hideLoadingOverlay()
    }
    
    override func onLetterEditorDidUpdate() {
        logic.picklistsDidUpdate()
        letterEditorViewController?.refresh()
        coverLetterViewController?.refreshFromPresenter()
    }
    
}

