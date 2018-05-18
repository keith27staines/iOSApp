//
//  F4SRequestCompanyDocumentViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 30/04/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class F4SRequestCompanyDocumentViewController: UIViewController {

    @IBOutlet weak var explanatoryText: UILabel!
    
    var documentModel: F4SCompanyDocumentsModel!
  
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let requestableDocuments = documentModel.requestableDocuments else {
            return
        }
        
        if requestableDocuments.count == 1 {
            explanatoryText.text = NSLocalizedString("This company has not provided this document yet", comment: "")
        } else {
            explanatoryText.text = NSLocalizedString("This company has not provided these documents yet", comment: "")
        }
    }

}

extension F4SRequestCompanyDocumentViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentModel.requestableDocuments?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "F4SRequestCompanyDocumentTableViewCell")!
        guard let documentCell = cell as? F4SRequestCompanyDocumentTableViewCell else {
            return cell
        }
        let document = documentModel.requestableDocuments![indexPath.row]
        documentCell.companyDocument = document
        return documentCell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let document = documentModel.requestableDocuments![indexPath.row]
        if document.status == CompanyDocument.Status.requested.rawValue {
            return nil
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        let document = documentModel.requestableDocuments![indexPath.row]
        if document.status == CompanyDocument.Status.unrequested.rawValue {
            let cell = tableView.cellForRow(at: indexPath) as? F4SRequestCompanyDocumentTableViewCell
            cell?.activitySpinner.isHidden = false
            cell?.activitySpinner.startAnimating()
            documentModel.requestDocuments([document]) { (result) in
                switch result {
                case .error(_):
                    break
                case .success(_):
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                cell?.activitySpinner.stopAnimating()
            }
        }
    }
}
