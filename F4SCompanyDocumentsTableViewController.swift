//
//  F4SCompanyDocumentsTableViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 19/04/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit
import Reachability

class F4SCompanyDocumentsTableViewController: UITableViewController {
    var delegate: F4SCompanyDocumentsTableViewControllerDelegate?
    var selectedIndexPath: IndexPath?
    
    var companyDocumentModel: F4SCompanyDocumentsModel!

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let model = companyDocumentModel else {
            return 0
        }
        return model.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let model = companyDocumentModel else {
            return 0
        }
        return model.rowsInSection(section: section)
    }
    
    enum DocumentSection : Int {
        case availableDocuments = 0
        case unavailableDocuments = 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = companyDocumentModel.document(indexPath).name
        if let documentSection = DocumentSection(rawValue: indexPath.section) {
            switch documentSection {
            case .availableDocuments:
                cell.imageView?.image = UIImage(named: "company_doc")
            case .unavailableDocuments:
                cell.imageView?.image = UIImage(named: "ui-company-upload-doc-off-icon")
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        guard let documentSection = DocumentSection(rawValue: indexPath.section) else {
            return
        }
        switch documentSection {
        case .availableDocuments:
            performSegue(withIdentifier: "showDocument", sender: self)
        case .unavailableDocuments:
            performSegue(withIdentifier: "requestDocument", sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = selectedIndexPath else {
            return
        }
        let selectedDocument = companyDocumentModel.document(indexPath)

        let vc = segue.destination
        if segue.identifier == "showDocument" {
            guard let documentController = vc as? F4SDocumentViewController else {
                return
            }
            documentController.documentUrl = selectedDocument.url
            return
        }
        
        if segue.identifier == "requestDocument" {
            guard let vc = vc as? F4SRequestCompanyDocumentViewController else {
                return
            }
            vc.documentModel = companyDocumentModel
            return
        }
    }
}
