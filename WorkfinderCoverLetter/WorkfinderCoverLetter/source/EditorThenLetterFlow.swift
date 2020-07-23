
import WorkfinderCommon
import WorkfinderUI
import WorkfinderCoordinators

public class EditorThenLetterFlow: CoverLetterFlow {
    
    public override var messageHandler: UserMessageHandler? { letterEditorViewController?.messageHandler }
    
    lazy var presenter: LetterEditorPresenter = {
        LetterEditorPresenter(coordinator: self, logic: logic)
    }()
    
    override public func start() {
        super.start()
        let vc = LetterEditorViewController(presenter: presenter)
        self.letterEditorViewController = vc
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    override func onLetterEditorTapPrimaryButton() {
        let presenter = CoverLetterViewPresenter(
            coordinator: self,
            primaryButtonTitle: "Submit application",
            logic: logic)
        let vc = CoverLetterViewController(presenter: presenter)
        self.coverLetterViewController = vc
        navigationRouter.push(viewController: vc, animated: true)
    }

    override func onLetterEditorDismiss() {
        finishWorkflow(cancelled: true)
    }

    override func onCoverLetterDismiss() {
        // nothing to do, the back button or gesture causes the navigator to pop the stack which is all that is required here
    }

    override func onCoverLetterTapPrimaryButton() {
        finishWorkflow(cancelled: false)
    }
    
    override func onCoverLetterTapEdit() {
        navigationRouter.pop(animated: true)
    }
    
}
