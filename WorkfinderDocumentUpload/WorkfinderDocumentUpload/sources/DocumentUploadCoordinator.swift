
import WorkfinderCommon
import WorkfinderServices
import WorkfinderCoordinators

public protocol DocumentUploadCoordinatorParentProtocol: class {
    func onSkipDocumentUpload()
    func onUploadComplete()
}

public class DocumentUploadCoordinator: CoreInjectionNavigationCoordinator {
    var delegate: DocumentUploadCoordinatorParentProtocol?
    weak var addFileViewController: AddFileViewController?
    weak var uploadViewController: UploadViewController?
    
    func onSkip() {
        delegate?.onSkipDocumentUpload()
    }
    
    func onUploadComplete() {
        navigationRouter.dismiss(animated: true, completion: nil)
        delegate?.onUploadComplete()
    }
    
    func onUploadCancelled() {
        guard let addFileViewController = addFileViewController else { return }
        navigationRouter.popToViewController(addFileViewController, animated: true)
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
        delegate?.onSkipDocumentUpload()
        let presenter = AddFilePresenter(coordinator: self, placementUuid: "")
        let vc = AddFileViewController(coordinator: self, presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
        addFileViewController = vc
    }
    
    func upload(filename: String,
                data: Data,
                metadata: [String:String],
                to urlString: String,
                method: RequestVerb
    ) {
        let service = DocumentUploadService(networkConfig: injected.networkConfig)
        let uploader = DocumentUploader(service: service)
        let presenter = UploadPresenter(
            coordinator: self,
            filename: filename,
            fileBytes: data,
            metadata: metadata,
            to: urlString,
            method: method,
            uploader: uploader
        )
        let vc = UploadViewController(coordinator: self, presenter: presenter)
        navigationRouter.present(vc, animated: true, completion: nil)
        uploadViewController = vc
    }
    
    
}
