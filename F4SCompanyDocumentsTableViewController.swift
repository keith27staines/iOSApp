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
    var selectedDocument: CompanyDocument?
    
    var companyDocumentModel: F4SCompanyDocumentsModel!

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let model = companyDocumentModel else {
            return 0
        }
        return model.documents?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = companyDocumentModel.document(indexPath).name
        cell.imageView?.image = UIImage(named: "company_doc")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedDocument = companyDocumentModel.document(indexPath)
        performSegue(withIdentifier: "showDocument", sender: self)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination
        if segue.identifier == "showDocument" {
            guard let documentController = vc as? F4SDocumentViewController else {
                return
            }
            guard let selectedDocument = selectedDocument else {
                return
            }
            documentController.documentUrl = selectedDocument.url
        }
    }
}
