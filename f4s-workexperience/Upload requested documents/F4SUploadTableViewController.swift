//
//  F4SUploadTableTableViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 22/05/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class F4SUploadTableViewController: UITableViewController {
    
    var model: F4SUploadRequestedDocumentsTableViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelection = false
        tableView.estimatedRowHeight = 60.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return model?.numberOfSections ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfRowsInSection(section: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! F4SUrlDescriptorTableViewCell
        cell.documentUrlDescriptor = model.descriptorForIndexPath(indexPath)
        cell.deleteButtonWasPressed = { [weak self] cell in
            guard let strongSelf = self, let indexPath = strongSelf.tableView.indexPath(for: cell) else { return }
            strongSelf.collapseExpandedRow()
            var descriptor = strongSelf.model.descriptorForIndexPath(indexPath)
            descriptor.urlString = ""
            descriptor.isExpanded = false
            let affectedIndexPaths = strongSelf.model.setDescriptorForIndexPath(indexPath, descriptor: descriptor)
            tableView.reloadRows(at: affectedIndexPaths, with: .automatic)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let _ = tableView.cellForRow(at: indexPath) as? F4SUrlDescriptorTableViewCell else { return }
        let descriptor = model.descriptorForIndexPath(indexPath)
        guard !descriptor.isValidUrl else {
            // contains a valid url so just toggle the expansion of the row
            if let affectedIndexPaths = model.toggleExpansionAtIndexPath(indexPath: indexPath) {
                tableView.reloadRows(at: affectedIndexPaths, with: .automatic)
            }
            return
        }
        
        // doesn't contain a valid url so can we paste in one from the pasteboard?
        let pasteText = UIPasteboard.general.string ?? ""
        guard let url = URL(string: pasteText), UIApplication.shared.canOpenURL(url) else {
            collapseExpandedRow()
            let alert = UIAlertController(title: "Not a valid link", message: "Please copy a valid link to paste in", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard model.urlIsNew(url: url) else {
            let alert = UIAlertController(title: "You have already added this link", message: "The link you are trying to add now has been added already! Please use a different one", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        let _ = model.setDescriptorForIndexPath(indexPath, title: "", type: descriptor.docType, urlString: pasteText, includeInApplication: true, isExpanded: false)
        expandRowAtIndexPath(indexPath: indexPath)
    }
    
    func expandRowAtIndexPath(indexPath: IndexPath) {
        let affectedIndexPaths = model.expandAtIndexPath(indexPath)
        tableView.reloadRows(at: affectedIndexPaths, with: .automatic)
    }
    
    func collapseExpandedRow() {
        if let affectedIndexPaths = model.collapseExpanded() {
            tableView.reloadRows(at: affectedIndexPaths, with: .automatic)
        }
    }

}
