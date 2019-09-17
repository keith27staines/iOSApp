import Foundation
import WorkfinderCommon
import WorkfinderCoordinators

let __bundle = Bundle(identifier: "com.f4s.WorkfinderDocumentUploadUseCase")

public class DocumentUploadCoordinator : CoreInjectionNavigationCoordinator {
    let mode: UploadScenario
    var popOnCompletion: Bool = false
    var root: UIViewController!
    
    public var didFinish: ((DocumentUploadCoordinator)->Void)?
    
    let placementUuid: F4SUUID
    let documentService: F4SPlacementDocumentServiceProtocol
    let documentUploaderFactory: F4SDocumentUploaderFactoryProtocol
    
    public init(parent: Coordinating?,
                navigationRouter: NavigationRoutingProtocol,
                inject: CoreInjectionProtocol,
                mode: UploadScenario,
                placementUuid: F4SUUID,
                documentService: F4SPlacementDocumentServiceProtocol,
                documentUploaderFactory: F4SDocumentUploaderFactoryProtocol) {
        self.placementUuid = placementUuid
        self.documentService = documentService
        self.mode = mode
        self.documentUploaderFactory = documentUploaderFactory
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    public override func start() {
        let addDocumentsController = UIStoryboard(name: "DocumentCapture", bundle: __bundle).instantiateInitialViewController() as! F4SAddDocumentsViewController
        switch mode {
        case .applyWorkflow:
            addDocumentsController.documentModel = F4SDocumentUploadWhileApplyingModel(
                delegate: addDocumentsController,
                placementUuid: placementUuid,
                documentService: documentService,
                documents: [])
        case .businessLeaderRequest(let requestModel):
            let placementUuid = requestModel.placementUuid
            let documents = requestModel.documents
            addDocumentsController.documentModel = F4SDocumentUploadAtBLRequestModel(
                delegate: addDocumentsController,
                placementUuid: placementUuid,
                documentService: documentService,
                documents: documents)
        }
        addDocumentsController.placementUuid = placementUuid
        addDocumentsController.uploadScenario = mode
        addDocumentsController.coordinator = self
        navigationRouter.push(viewController: addDocumentsController, animated: true)
        root = addDocumentsController
    }
    
    func documentUploadDidFinish() {
        if popOnCompletion { navigationRouter.popToViewController(root, animated: true) }
        parentCoordinator?.childCoordinatorDidFinish(self)
        didFinish?(self)
    }
    
    func documentUploadDidCancel() {
        navigationRouter.popToViewController(root, animated: true)
        navigationRouter.pop(animated: false)
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
    
    func showDocument(_ document: F4SDocument?) {
        guard let document = document else { return }
        let storyboard = UIStoryboard(name: "DocumentCapture", bundle: __bundle)
        let viewer = storyboard.instantiateViewController(withIdentifier: "F4SDCDocumentViewerController") as! F4SDCDocumentViewerController
        viewer.document = document
        navigationRouter.push(viewController: viewer, animated: true)
    }
    
    func showPickMethodForDocument(_ document: F4SDocument?, addDocumentDelegate delegate: F4SDCAddDocumentViewControllerDelegate) {
        guard let document = document else { return }
        let storyboard = UIStoryboard(name: "DocumentCapture", bundle: __bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "F4SDCAddDocumentViewController") as! F4SDCAddDocumentViewController
        vc.delegate = delegate
        vc.documentTypes = [document.type]
        vc.document = document
        vc.coordinator = self
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    func showPickMethodForNewDocument(documentTypes: [F4SUploadableDocumentType], addDocumentDelegate delegate: F4SDCAddDocumentViewControllerDelegate) {
        let storyboard = UIStoryboard(name: "DocumentCapture", bundle: __bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "F4SDCAddDocumentViewController") as! F4SDCAddDocumentViewController
        vc.delegate = delegate
        vc.documentTypes = documentTypes
        vc.document = F4SDocument(type: .cv)
        vc.coordinator = self
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    func postDocuments(documentModel: F4SDocumentUploadModelBase) {
        let postDocumentsController = PostDocumentsWithDataViewController(uploaderFactory: documentUploaderFactory)
        postDocumentsController.delegate = self
        postDocumentsController.documentModel = documentModel
        navigationRouter.push(viewController: postDocumentsController, animated: true)
    }
}

extension DocumentUploadCoordinator : PostDocumentsWithDataViewControllerDelegate {
    func postDocumentsControllerDidCancel(_ controller: PostDocumentsWithDataViewController) {
        navigationRouter.pop(animated: true)
    }
    
    func postDocumentsControllerDidCompleteUpload(_ controller: PostDocumentsWithDataViewController) {
        documentUploadDidFinish()
    }
}
