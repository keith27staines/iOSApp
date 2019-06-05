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
                        strongSelf.coordinator?.documentUploadDidFinish()
                    }
                } else {
                    sharedUserMessageHandler.hideLoadingOverlay()
                    strongSelf.displayTryAgain(completion: strongSelf.performPrimaryActionForApplyMode)
                }
            }
        }
    }
    
    func postDocumentsWithData() {
        coordinator?.postDocuments(documentModel: documentModel)
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
}
