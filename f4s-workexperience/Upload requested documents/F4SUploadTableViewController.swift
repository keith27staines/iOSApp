//
//  F4SUploadTableTableViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 22/05/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class F4SUploadTableViewController: UITableViewController {

    var documentUrlDescriptors: [F4SDocumentUrlDescriptor]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelection = false
        tableView.estimatedRowHeight = 40.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentUrlDescriptors?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! F4SUrlDescriptorTableViewCell
        cell.documentUrlDescriptor = documentUrlDescriptors[indexPath.row]
        cell.deleteButtonWasPressed = { [weak self] cell in
            guard let strongSelf = self else { return }
            let current = strongSelf.documentUrlDescriptors[indexPath.row]
            strongSelf.documentUrlDescriptors[indexPath.row] = F4SDocumentUrlDescriptor(title: "", docType: current.docType, urlString: "", includeInApplication: true, isExpanded: false)
            strongSelf.collapseExpandedRow()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let cell = tableView.cellForRow(at: indexPath) as? F4SUrlDescriptorTableViewCell else { return }
        let descriptor = documentUrlDescriptors[indexPath.row]
        guard !descriptor.isValidUrl else {
            // contains a valid url so just toggle the expansion of the row
            toggleExpansionAtIndexPath(indexPath: indexPath)
            return
        }
        
        // doesn't contain a valid url
        let pasteText = UIPasteboard.general.string ?? ""
        guard let url = URL(string: pasteText), UIApplication.shared.canOpenURL(url) else {
            collapseExpandedRow()
            let alert = UIAlertController(title: "Not a valid link", message: "Please copy a valid link to paste in", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard urlIsNew(url: url) else {
            let alert = UIAlertController(title: "You have already added this link", message: "The link you are trying to paste now is already here! Please use a different one", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        documentUrlDescriptors[indexPath.row] = F4SDocumentUrlDescriptor(title: "", docType: descriptor.docType, urlString: pasteText, includeInApplication: true, isExpanded: false)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        expandRowAtIndexPath(indexPath: indexPath)
    }
    
    func urlIsNew(url: URL) -> Bool {
        for descriptor in documentUrlDescriptors {
            if descriptor.url == url {
                return false
            }
        }
        return true
    }
    
    var expandedIndexPath: IndexPath?
    
    func toggleExpansionAtIndexPath(indexPath: IndexPath) {
        if indexPath == expandedIndexPath {
            collapseExpandedRow()
        } else {
            expandRowAtIndexPath(indexPath: indexPath)
        }
    }
    
    func expandRowAtIndexPath(indexPath: IndexPath) {
        if indexPath == expandedIndexPath {
            tableView.reloadRows(at: [indexPath], with: .automatic)
            return
        }
        var affectedIndexPaths : [IndexPath] = [indexPath]
        let current = expandedIndexPath
        if current != nil {
            documentUrlDescriptors[current!.row].isExpanded = false
            affectedIndexPaths.append(current!)
        }
        documentUrlDescriptors[indexPath.row].isExpanded = true
        expandedIndexPath = indexPath
        tableView.reloadRows(at: affectedIndexPaths, with: .automatic)
    }
    
    func collapseExpandedRow() {
        guard let explandedIndexPath = expandedIndexPath else {
            return
        }
        documentUrlDescriptors[explandedIndexPath.row].isExpanded = false
        self.expandedIndexPath = nil
        tableView.reloadRows(at: [explandedIndexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cell = tableView.cellForRow(at: indexPath) as? F4SUrlDescriptorTableViewCell else {
            return 40.0
        }
        if documentUrlDescriptors[indexPath.row].isExpanded {
            return cell.requiredHeight(numberOfLines: 0)
        } else {
            return cell.requiredHeight(numberOfLines: 1)
        }
    }

}
