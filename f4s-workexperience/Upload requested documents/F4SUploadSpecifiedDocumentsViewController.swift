//
//  F4SMessageActionDocumentUploadViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 21/05/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class F4SUploadSpecifiedDocumentsViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var uploadButton: UIButton!
    
    @IBOutlet weak var introductionText: UILabel!
    
    var companyName: String = ""
    
    var action: F4SAction! {
        didSet {
            if let action = action {
                model = F4SUploadRequestedDocumentsTableViewModel(action: action)
            }
        }
    }
    
    var model: F4SUploadRequestedDocumentsTableViewModel! {
        didSet {
            updateFromModel()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedTableView" {
            uploadTableController = segue.destination as? F4SUploadTableViewController
            uploadTableController?.model = model
        }
    }
    
    var uploadTableController: F4SUploadTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyle()
        navigationItem.title = "Provide info"
        introductionText.text = NSLocalizedString("Add links to the information requested by \(companyName) in their recent message to you", comment: "")
        uploadButton.isEnabled = model.canSubmitToServer()
        
        NotificationCenter.default.addObserver(forName: Notification.Name.uploadRequestSubmitStateUpdated, object: nil, queue: nil) { [weak self] (notification) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                let canSubmit = strongSelf.model.canSubmitToServer()
                strongSelf.uploadButton.isEnabled = canSubmit
            }

        }
    }
    
    func applyStyle() {
        Skinner().apply(buttonSkin: skin?.primaryButtonSkin, to: uploadButton)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.isTranslucent = true
        updateFromModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.isTranslucent = false
    }

    func updateFromModel() {
        uploadTableController?.tableView.reloadData()
    }
    
    @IBAction func uploadDocumentUrls(_ sender: UIButton) {
        guard model.canSubmitToServer() else { return }
        MessageHandler.sharedInstance.showLightLoadingOverlay(self.view)
        model.submitToServer { [weak self] result in
            guard let strongSelf = self else {
                return }
            DispatchQueue.main.async {
                MessageHandler.sharedInstance.hideLoadingOverlay()
                switch result {
                case .error(let error):
                    MessageHandler.sharedInstance.display(error, parentCtrl: strongSelf)
                case .success( _ ):
                    let alert = UIAlertController(title: "Uploaded!", message: "We will pass on these links to \(strongSelf.companyName)\n\nThank you!", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Close", style: .default, handler: { (_) in
                        strongSelf.navigationController?.popViewController(animated: true)
                    })
                    alert.addAction(action)
                    strongSelf.present(alert, animated: true)
                }
            }
        }
    }
}


