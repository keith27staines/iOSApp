//
//  F4SCompanyDocumentsTableViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 19/04/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

public struct CompanyDocument {
    var name: String
    var url: URL {
        return URL(string: "https://www.raspberrypi.org")!
    }
}

typealias CompanyDocuments = [CompanyDocument]

protocol F4SCompanyDocumentsTableViewControllerDelegate {
    func receivedTap(_ controller: F4SCompanyDocumentsTableViewController)
}

class F4SCompanyDocumentsTableViewController: UITableViewController {
    var delegate: F4SCompanyDocumentsTableViewControllerDelegate? = nil
    var selectedDocument: CompanyDocument?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var companyDocuments: CompanyDocuments {
        return [
            CompanyDocument(name: "Employer's Liability Insurance"),
            CompanyDocument(name: "Safe Guarding Certificate"),
            CompanyDocument(name: "Other document 1"),
            CompanyDocument(name: "Other document 2"),
            CompanyDocument(name: "Other document 3")]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return companyDocuments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = companyDocuments[indexPath.row].name
        cell.imageView?.image = UIImage(named: "company_doc")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedDocument = companyDocuments[indexPath.row]
        performSegue(withIdentifier: "showDocument", sender: self)
        delegate?.receivedTap(self)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
