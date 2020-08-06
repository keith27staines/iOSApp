
import WorkfinderCommon
import WorkfinderCoordinators

public protocol DocumentUploadCoordinatorParentProtocol: class {
    func onSkipDocumentUpload()
    func onUploadComplete()
}

public class DocumentUploadCoordinator: CoreInjectionNavigationCoordinator {
    var delegate: DocumentUploadCoordinatorParentProtocol?
    
    func onSkip() {
        delegate?.onSkipDocumentUpload()
    }
    
    func onUploadComplete() {
        delegate?.onUploadComplete()
    }
    
    public init(
        parent: Coordinating?,
        navigationRouter: NavigationRoutingProtocol,
        inject: CoreInjectionProtocol,
        delegate: DocumentUploadCoordinatorParentProtocol) {
        self.delegate = delegate
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    public override func start() {
        let presenter = AddFilePresenter(coordinator: self)
        let vc = AddFileViewController(coordinator: self, presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    
}
