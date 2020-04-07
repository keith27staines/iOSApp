
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
    let templateProvider: TemplateProviderProtocol
    
    public init(parent: Coordinating?, navigationRouter: NavigationRoutingProtocol, inject: CoreInjectionProtocol, candidateDateOfBirth: Date) {
        self.templateProvider = TemplateProvider(candidateDateOfBirth: candidateDateOfBirth)
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    lazy var presenter: CoverLetterViewPresenterProtocol = {
        let presenter = CoverLetterViewPresenter(
            coordinator: self,
            templateProvider: self.templateProvider)
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
    
    let picklistsDictionary: PicklistsDictionary = [
        .attributes: Picklist(type: .attributes, maximumPicks: 3),
        .roles: Picklist(type: .roles, maximumPicks: 1),
        .skills: Picklist(type: .skills, maximumPicks: 3),
        .universities: Picklist(type: .universities, maximumPicks: 1)
    ]
    
    var picklistsDidUpdate: ((PicklistsDictionary) -> Void)?
    public func onDidTapSelectOptions(completion: @escaping ((PicklistsDictionary) -> Void)) {
        picklistsDidUpdate = completion
        let presenter = LetterEditorPresenter(coordinator: self, picklists: self.picklistsDictionary)
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
    func showPicklist(_ picklist: Picklist) {
        let vc = PicklistViewController(coordinator: self, picklist: picklist)
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    func letterEditor(view: LetterEditorViewProtocol, updatedPickLists picklistsDictionary: PicklistsDictionary) {
        picklistsDidUpdate?(picklistsDictionary)
    }
}

extension CoverLetterCoordinator: PicklistCoordinator {
    
}
