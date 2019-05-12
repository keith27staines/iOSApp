//
//  AddDocumentsViewController+PerformPrimaryActionForApplyMode.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 06/11/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit
import WorkfinderCommon
import WorkfinderNetworking

extension F4SAddDocumentsViewController : PostDocumentsWithDataViewControllerDelegate {
    func postDocumentsControllerDidCancel(_ controller: PostDocumentsWithDataViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func postDocumentsControllerDidCompleteUpload(_ controller: PostDocumentsWithDataViewController) {
        navigationController?.popViewController(animated: true)
        switch mode {
        case .applyWorkflow:
            submitApplication(applicationContext: applicationContext)
        case .businessLeaderRequest(_):
            navigationController?.popViewController(animated: true)
        }
    }
}

extension F4SAddDocumentsViewController {
    
    func performPrimaryActionForBLRequestMode() {
        primaryActionButton.isEnabled = false
        sharedUserMessageHandler.showLoadingOverlay(view)
        documentModel.putDocumentsWithRemoteUrls { (success) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.primaryActionButton.isEnabled = true
                if success {
                    sharedUserMessageHandler.hideLoadingOverlay()
                    if !strongSelf.documentModel.documentsWithData().isEmpty {
                        strongSelf.postDocumentsWithData()
                    } else {
                        strongSelf.dismiss(animated: true, completion: nil)
                    }
                } else {
                    sharedUserMessageHandler.hideLoadingOverlay()
                    strongSelf.displayTryAgain(completion: strongSelf.performPrimaryActionForBLRequestMode)
                }
            }
        }
    }
    
    func performPrimaryActionForApplyMode() {
        primaryActionButton.isEnabled = false
        sharedUserMessageHandler.showLoadingOverlay(view)
        documentModel.putDocumentsWithRemoteUrls { (success) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.primaryActionButton.isEnabled = true
                if success {
                    if !strongSelf.documentModel.documentsWithData().isEmpty {
                        sharedUserMessageHandler.hideLoadingOverlay()
                        strongSelf.postDocumentsWithData()
                    } else {
                        strongSelf.submitApplication(applicationContext: strongSelf.applicationContext)
                    }
                } else {
                    sharedUserMessageHandler.hideLoadingOverlay()
                    strongSelf.displayTryAgain(completion: strongSelf.performPrimaryActionForApplyMode)
                }
            }
        }
    }
    
    func postDocumentsWithData() {
        let postDocumentsController = PostDocumentsWithDataViewController()
        postDocumentsController.delegate = self
        postDocumentsController.documentModel = documentModel
        navigationController?.pushViewController(postDocumentsController, animated: true)
    }
    
    func displayTryAgain(completion: @escaping ()->()) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: "No internet connection", message: "Please make sure you have an internet connection and try again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: { (action) in
                completion()
            }))
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    func submitApplication(applicationContext: F4SApplicationContext) {
        let user = applicationContext.user!
        userService.updateUser(user: user) { [weak self] (result) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                sharedUserMessageHandler.hideLoadingOverlay()
                switch result {
                case .success(let userModel):
                    guard let uuid = userModel.uuid else {
                        sharedUserMessageHandler.displayWithTitle("Oops something went wrong", "Workfinder cannot complete this operation", parentCtrl: strongSelf)
                        return
                    }
                    user.updateUuid(uuid: uuid)
                    F4SUserRepository().save(user: user)
                    updateWEXSessionManagerWithUserUUID(uuid)
                    F4SNetworkSessionManager.shared.rebuildSessions() // Ensure session manager is aware of the possible change of user uuid
                    var updatedContext = applicationContext
                    updatedContext.user = user
                    var updatedPlacement = applicationContext.placement!
                    updatedPlacement.status = WEXPlacementState.applied
                    updatedContext.placement = updatedPlacement
                    strongSelf.applicationContext = updatedContext
                    PlacementDBOperations.sharedInstance.savePlacement(placement: updatedPlacement)
                    UserDefaults.standard.set(true, forKey: strongSelf.consentPreviouslyGivenKey)
                    strongSelf.afterSubmitApplication(applicationContext: updatedContext)
                case .error(let error):
                    sharedUserMessageHandler.display(error, parentCtrl: strongSelf, cancelHandler: nil) {
                        sharedUserMessageHandler.showLoadingOverlay(strongSelf.view)
                        strongSelf.submitApplication(applicationContext: applicationContext)
                    }
                }
            }
        }
    }
    
    func afterSubmitApplication(applicationContext: F4SApplicationContext) {
        TabBarCoordinator.sharedInstance.presentSuccessExtraInfoPopover(
            parentCtrl: self)
    }
}
