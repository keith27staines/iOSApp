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
    
    @IBOutlet weak var lifeskillsStack: UIStackView!
    
    @IBOutlet weak var lifeSkillsSwitch: UISwitch!
    
    
    @IBAction func lifeSkillsSwitchChanged(_ sender: Any) {
        model.userHasLifeskillsCertificate = lifeSkillsSwitch.isOn
        updateFromModel()
    }
    
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
        F4SButtonStyler.apply(style: .primary, button: uploadButton)
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
        lifeskillsStack?.isHidden = !model.isLifeSkillsCertificateRequested
        lifeSkillsSwitch?.isOn = model.userHasLifeskillsCertificate
        uploadTableController?.tableView.reloadData()
    }
    
    @IBAction func uploadDocumentUrls(_ sender: UIButton) {
    }
    
}


