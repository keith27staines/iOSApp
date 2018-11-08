//
//  AddDocumentsViewController+PerformPrimaryActionForApplyMode.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 06/11/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

extension F4SAddDocumentsViewController {
    func performPrimaryActionForApplyMode() {
        primaryActionButton.isEnabled = false
        continueAsyncWorker()
    }
    
    func continueAsyncWorker() {
        MessageHandler.sharedInstance.showLoadingOverlay(view)
        documentModel.putDocuments { (success) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.primaryActionButton.isEnabled = true
                if success {
                    strongSelf.submitApplication(applicationContext: strongSelf.applicationContext)
                } else {
                    MessageHandler.sharedInstance.hideLoadingOverlay()
                    strongSelf.displayTryAgain(completion: strongSelf.continueAsyncWorker)
                }
            }
        }
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
        var user = applicationContext.user!
        userService.updateUser(user: user) { [weak self] (result) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                MessageHandler.sharedInstance.hideLoadingOverlay()
                switch result {
                case .success(let userModel):
                    guard let uuid = userModel.uuid else {
                        MessageHandler.sharedInstance.displayWithTitle("Oops something went wrong", "Workfinder cannot complete this operation", parentCtrl: strongSelf)
                        return
                    }
                    user.updateUuidAndPersistToLocalStorage(uuid: uuid)
                    F4SNetworkSessionManager.shared.rebuildSessions() // Ensure session manager is aware of the possible change of user uuid
                    var updatedContext = applicationContext
                    updatedContext.user = user
                    var updatedPlacement = applicationContext.placement!
                    updatedPlacement.status = F4SPlacementStatus.applied
                    updatedContext.placement = updatedPlacement
                    strongSelf.applicationContext = updatedContext
                    PlacementDBOperations.sharedInstance.savePlacement(placement: updatedPlacement)
                    UserDefaults.standard.set(true, forKey: strongSelf.consentPreviouslyGivenKey)
                    strongSelf.afterSubmitApplication(applicationContext: updatedContext)
                case .error(let error):
                    MessageHandler.sharedInstance.display(error, parentCtrl: strongSelf, cancelHandler: nil) {
                        MessageHandler.sharedInstance.showLoadingOverlay(strongSelf.view)
                        strongSelf.submitApplication(applicationContext: applicationContext)
                    }
                }
            }
        }
    }
    
    func afterSubmitApplication(applicationContext: F4SApplicationContext) {
        CustomNavigationHelper.sharedInstance.presentSuccessExtraInfoPopover(
            parentCtrl: self)
    }
}
