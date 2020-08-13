
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

    override func onCoverLetterDismiss() {
        finishWorkflow(cancelled: true)
    }
    
    override func onLetterEditorTapPrimaryButton() {
        logic.save()
        navigationRouter.pop(animated: true)
    }
    
    override func onLetterEditorDismiss() {
        logic.save()
    }
    
    override func onLetterEditorDidUpdate() {
        logic.picklistsDidUpdate()
        letterEditorViewController?.refresh()
        coverLetterViewController?.refreshFromPresenter()
    }
    
}

