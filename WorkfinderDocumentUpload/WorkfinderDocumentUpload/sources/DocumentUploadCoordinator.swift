
import WorkfinderCommon
import WorkfinderServices
import WorkfinderCoordinators

enum MimeType: String {
    case pdf = "application/pdf"
    case doc = "application/doc"
    case docx = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    init?(fileExtension: String) {
        switch fileExtension {
        case "pdf":
            self = .pdf
            return
        case "doc":
            self = .doc
            return
        case "docx":
            self = .docx
            return
        default:
            return nil
        }
    }
}

public protocol DocumentUploadCoordinatorParentProtocol: class {
    func onSkipDocumentUpload()
    func onUploadComplete()
}

public enum AppModel {
    case placement
    var name: String {
        switch self {
        case .placement: return "placements_placement"
        }
    }
}

public class DocumentUploadCoordinator: CoreInjectionNavigationCoordinator {
    var delegate: DocumentUploadCoordinatorParentProtocol?
    weak var addFileViewController: AddFileViewController?
    weak var uploadViewController: UploadViewController?
    let appModel: AppModel
    let objectUuid: F4SUUID
    let showBackButton: Bool
    var log: F4SAnalyticsAndDebugging { injected.log }
    
    func onSkip() {
        log.track(.document_upload_skip)
        delegate?.onSkipDocumentUpload()
    }
    
    func onUploadComplete() {
        log.track(.document_upload_convert)
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
        delegate: DocumentUploadCoordinatorParentProtocol,
        appModel: AppModel,
        objectUuid: F4SUUID,
        showBackButton: Bool) {
        self.delegate = delegate
        self.appModel = appModel
        self.objectUuid = objectUuid
        self.showBackButton = showBackButton
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    public override func start() {
        log.track(.document_upload_start)
        let presenter = AddFilePresenter(coordinator: self)
        let vc = AddFileViewController(
            coordinator: self,
            presenter: presenter,
            showBackButton: showBackButton
        )
        navigationRouter.push(viewController: vc, animated: true)
        addFileViewController = vc
    }
    
    func upload(filename: String,
                data: Data,
                mime: String,
                metadata: [String:String]
    ) {
        var metadata = metadata
        metadata["app_model"] = appModel.name
        metadata["uuid"] = objectUuid
        let service = DocumentUploadService(networkConfig: injected.networkConfig)
        let toUrl = injected.networkConfig.workfinderApiEndpoint.workfinderAPiUrl.appendingPathComponent("documents/")
        let uploader = DocumentUploader(
            service: service,
            filename: filename,
            mime: mime,
            filedata: data,
            metadata: metadata,
            to: toUrl,
            method: .post
        )
        let presenter = UploadPresenter(coordinator: self, uploader: uploader)
        let vc = UploadViewController(coordinator: self, presenter: presenter)
        navigationRouter.present(vc, animated: true, completion: nil)
        uploadViewController = vc
    }
    
    
}
