//
//  DocumentUploadCoordinator.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 26/05/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

class DocumentUploadCoordinator : CoreInjectionNavigationCoordinator {
    let applicationContext: F4SApplicationContext?
    
    let mode: F4SAddDocumentsViewController.Mode
    var popOnCompletion: Bool = false
    
    var didFinish: ((DocumentUploadCoordinator)->Void)?
    
    init(parent: Coordinating?, navigationRouter: NavigationRoutingProtocol, inject: CoreInjectionProtocol, mode: F4SAddDocumentsViewController.Mode, applicationContext: F4SApplicationContext?) {
        self.applicationContext = applicationContext
        self.mode = mode
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    var root: UIViewController!
    override func start() {
        let addDocumentsController = UIStoryboard(name: "DocumentCapture", bundle: nil).instantiateInitialViewController() as! F4SAddDocumentsViewController
        addDocumentsController.applicationContext = applicationContext
        addDocumentsController.mode = mode
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
        let storyboard = UIStoryboard(name: "DocumentCapture", bundle: nil)
        let viewer = storyboard.instantiateViewController(withIdentifier: "F4SDCDocumentViewerController") as! F4SDCDocumentViewerController
        viewer.document = document
        navigationRouter.push(viewController: viewer, animated: true)
    }
    
    func showPickMethodForDocument(_ document: F4SDocument?, addDocumentDelegate delegate: F4SDCAddDocumentViewControllerDelegate) {
        guard let document = document else { return }
        let storyboard = UIStoryboard(name: "DocumentCapture", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "F4SDCAddDocumentViewController") as! F4SDCAddDocumentViewController
        vc.delegate = delegate
        vc.documentTypes = [document.type]
        vc.document = document
        vc.coordinator = self
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    func showPickMethodForNewDocument(documentTypes: [F4SUploadableDocumentType], addDocumentDelegate delegate: F4SDCAddDocumentViewControllerDelegate) {
        let storyboard = UIStoryboard(name: "DocumentCapture", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "F4SDCAddDocumentViewController") as! F4SDCAddDocumentViewController
        vc.delegate = delegate
        vc.documentTypes = documentTypes
        vc.document = F4SDocument(type: .cv)
        vc.coordinator = self
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    func postDocuments(documentModel: F4SDocumentUploadModelBase) {
        let postDocumentsController = PostDocumentsWithDataViewController()
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
