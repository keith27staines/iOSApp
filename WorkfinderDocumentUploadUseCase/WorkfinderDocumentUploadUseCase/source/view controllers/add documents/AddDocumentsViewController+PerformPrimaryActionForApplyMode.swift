import WorkfinderUI

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
        guard documentModel.documentsForUpload.count > 0 else {
            log?.track(event: .addDocumentsSkipTap, properties: nil)
            coordinator?.documentUploadDidFinish()
            return
        }
        log?.track(event: .addDocumentsUploadTap, properties: nil)
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
