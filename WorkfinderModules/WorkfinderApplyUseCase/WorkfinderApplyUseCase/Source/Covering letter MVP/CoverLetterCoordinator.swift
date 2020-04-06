
import UIKit
import WorkfinderCommon
import WorkfinderCoordinators

public protocol CoverletterCoordinatorProtocol: class {
    func start()
    func onCoverLetterDidDismiss()
    func onDidCompleteCoverLetter()
    func onDidTapSelectOptions(completion: @escaping((PicklistsDictionary)->Void))
}

public class CoverLetterCoordinator: CoreInjectionNavigationCoordinator, CoverletterCoordinatorProtocol  {
    
    lazy var presenter: CoverLetterViewPresenterProtocol = {
        let presenter = CoverLetterViewPresenter(
            coordinator: self,
            templateProvider: TemplateProvider())
        return presenter
    }()
    
    weak var coverLetterViewController: CoverLetterViewController?
    weak var letterEditorViewController: LetterEditorViewProtocol?
    
    override public func start() {
        super.start()
        let viewController = CoverLetterViewController(presenter: presenter)
        self.coverLetterViewController = viewController
        navigationRouter.push(viewController: viewController, animated: true)
    }
    
    
    var picklistsDidUpdate: ((PicklistsDictionary) -> Void)?
    public func onDidTapSelectOptions(completion: @escaping ((PicklistsDictionary) -> Void)) {
        picklistsDidUpdate = completion
        let presenter = LetterEditorPresenter(coordinator: self)
        let letterEditorViewController = LetterEditorViewController(presenter: presenter)
        self.letterEditorViewController = letterEditorViewController
        coverLetterViewController?.navigationController?.pushViewController(letterEditorViewController, animated: true)
    }
    
    public func onCoverLetterDidDismiss() {
        print("coordinator received: onDidCancelCoverLetter")
    }

    public func onDidCompleteCoverLetter() {
        print("coordinator received: onDidCompleteCoverLetter")
    }
}

extension CoverLetterCoordinator: LetterEditorCoordinatorProtocol {
    func letterEditor(view: LetterEditorViewProtocol, updatedPickLists picklistsDictionary: PicklistsDictionary) {
        picklistsDidUpdate?(picklistsDictionary)
    }
}
