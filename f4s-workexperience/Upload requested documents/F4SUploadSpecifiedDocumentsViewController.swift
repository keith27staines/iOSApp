//
//  F4SMessageActionDocumentUploadViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 21/05/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class F4SUploadSpecifiedDocumentsViewController: UIViewController {
    var action: F4SAction! {
        didSet {
            guard action.actionType == .uploadDocuments else {
                return
            }
            self.documentDescriptors = action!.argument(name: F4SActionArgumentName.documentType)!.value.map({ (docTypeName) -> F4SDocumentUrlDescriptor in
                let docType = F4SUploadableDocumentType(rawValue: docTypeName) ?? F4SUploadableDocumentType.other
                return F4SDocumentUrlDescriptor(title: "", docType: docType, urlString: "", includeInApplication: true, isExpanded: false)
            })
            uploadTableController?.documentUrlDescriptors = documentDescriptors
            let placementUuid = action.argument(name: F4SActionArgumentName.placementUuid)!.value.first
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedTableView" {
            uploadTableController = segue.destination as? F4SUploadTableViewController
            uploadTableController?.documentUrlDescriptors = documentDescriptors
        }
    }
    
    
    var uploadTableController: F4SUploadTableViewController?
    
    var documentDescriptors: [F4SDocumentUrlDescriptor] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        F4SButtonStyler.apply(style: .primary, button: uploadButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.isTranslucent = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.isTranslucent = false
    }

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var uploadButton: UIButton!
    
    
    @IBAction func uploadDocumentUrls(_ sender: UIButton) {
    }
    
}


