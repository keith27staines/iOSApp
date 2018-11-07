//
//  URLTableViewController.swift
//  UrlUploadDemo
//
//  Created by Keith Dev on 16/02/2018.
//  Copyright © 2018 Keith Dev. All rights reserved.
//

import UIKit

class URLTableViewController: UIViewController {
    
    var documentUploadModel: F4SDocumentUploadModel!
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelection = false
        tableView.estimatedRowHeight = 40.0
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func createNewLink() {
        guard let _ = documentUploadModel.createDescriptor(includeInApplication: false) else {
            return
        }
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .top)
        collapseExpandedRow()
    }
    
    func deleteUrlForCell(cell: UrlTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        var urlDescriptor = documentUploadModel.document(indexPath)
        urlDescriptor.remoteUrlString = ""
        documentUploadModel.deleteDocument(indexPath: indexPath)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

extension URLTableViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return documentUploadModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentUploadModel.numberOfRows(for: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UrlTableViewCell
        cell.document = documentUploadModel.document(indexPath)
        cell.deleteButtonWasPressed = deleteUrlForCell
        if documentUploadModel.document(indexPath).isExpanded {
            cell.label.numberOfLines = 0
            cell.label.lineBreakMode = .byCharWrapping
        } else {
            cell.label.numberOfLines = 1
            cell.label.lineBreakMode = .byTruncatingHead
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let cell = tableView.cellForRow(at: indexPath) as? UrlTableViewCell else { return }
        var urlDescriptor = documentUploadModel.document(indexPath)
        guard !urlDescriptor.hasValidRemoteUrl else {
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
        
        guard !documentUploadModel.contains(url: url) else {
            let alert = UIAlertController(title: "You have already added this link", message: "The link you are trying to paste now is already here! Please use a different one", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        urlDescriptor.remoteUrlString = pasteText
        documentUploadModel.setDocument(urlDescriptor, at: indexPath)
        cell.document = urlDescriptor
        expandRowAtIndexPath(indexPath: indexPath)
    }
    
    func toggleExpansionAtIndexPath(indexPath: IndexPath) {
        if indexPath == documentUploadModel.expandedIndexPath {
            collapseExpandedRow()
        } else {
            expandRowAtIndexPath(indexPath: indexPath)
        }
    }
    
    func expandRowAtIndexPath(indexPath: IndexPath) {
        if indexPath == documentUploadModel.expandedIndexPath {
            tableView.reloadRows(at: [indexPath], with: .automatic)
            return
        }
        var affectedIndexPaths : [IndexPath] = [indexPath]
        let current = documentUploadModel.expandedIndexPath
        if current != nil {
            affectedIndexPaths.append(current!)
        }
        documentUploadModel.expandDocument(at: indexPath)
        tableView.reloadRows(at: affectedIndexPaths, with: .automatic)
    }
    
    func collapseExpandedRow() {
        guard let explandedIndexPath = documentUploadModel.expandedIndexPath else {
            return
        }
        documentUploadModel.collapseAllRows()
        tableView.reloadRows(at: [explandedIndexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cell = tableView.cellForRow(at: indexPath) as? UrlTableViewCell else {
            return 40.0
        }
        if documentUploadModel.document(indexPath).isExpanded {
            return cell.requiredHeight(numberOfLines: 0)
        } else {
            return cell.requiredHeight(numberOfLines: 1)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            documentUploadModel.deleteDocument(indexPath: indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
}
