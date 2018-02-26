//
//  URLTableViewController.swift
//  UrlUploadDemo
//
//  Created by Keith Dev on 16/02/2018.
//  Copyright © 2018 Keith Dev. All rights reserved.
//

import UIKit

class URLTableViewController: UIViewController {
    
    var documentUrlModel: F4SDocumentUrlModel!
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelection = false
        tableView.estimatedRowHeight = 40.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func createNewLink() {
        guard let _ = documentUrlModel.createDescriptor(includeInApplication: false) else {
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
        var urlDescriptor = documentUrlModel.urlDescriptor(indexPath)
        urlDescriptor.urlString = ""
        documentUrlModel.deleteDescriptor(indexPath: indexPath)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

extension URLTableViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return documentUrlModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentUrlModel.numberOfRows(for: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UrlTableViewCell
        cell.documentUrlDescriptor = documentUrlModel.urlDescriptor(indexPath)
        cell.deleteButtonWasPressed = deleteUrlForCell
        if documentUrlModel.urlDescriptor(indexPath).isExpanded {
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
        var urlDescriptor = documentUrlModel.urlDescriptor(indexPath)
        guard !urlDescriptor.isValidUrl else {
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
        
        guard !documentUrlModel.contains(url: url) else {
            let alert = UIAlertController(title: "You have already added this link", message: "The link you are trying to paste now is already here! Please use a different one", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        urlDescriptor.urlString = pasteText
        documentUrlModel.setDescriptor(urlDescriptor, at: indexPath)
        cell.documentUrlDescriptor = urlDescriptor
        expandRowAtIndexPath(indexPath: indexPath)
    }
    
    func toggleExpansionAtIndexPath(indexPath: IndexPath) {
        if indexPath == documentUrlModel.expandedIndexPath {
            collapseExpandedRow()
        } else {
            expandRowAtIndexPath(indexPath: indexPath)
        }
    }
    
    func expandRowAtIndexPath(indexPath: IndexPath) {
        if indexPath == documentUrlModel.expandedIndexPath {
            tableView.reloadRows(at: [indexPath], with: .automatic)
            return
        }
        var affectedIndexPaths : [IndexPath] = [indexPath]
        let current = documentUrlModel.expandedIndexPath
        if current != nil {
            affectedIndexPaths.append(current!)
        }
        documentUrlModel.expandDescriptor(at: indexPath)
        tableView.reloadRows(at: affectedIndexPaths, with: .automatic)
    }
    
    func collapseExpandedRow() {
        guard let explandedIndexPath = documentUrlModel.expandedIndexPath else {
            return
        }
        documentUrlModel.collapseAllRows()
        tableView.reloadRows(at: [explandedIndexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cell = tableView.cellForRow(at: indexPath) as? UrlTableViewCell else {
            return 40.0
        }
        if documentUrlModel.urlDescriptor(indexPath).isExpanded {
            return cell.requiredHeight(numberOfLines: 0)
        } else {
            return cell.requiredHeight(numberOfLines: 1)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            documentUrlModel.deleteDescriptor(indexPath: indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
}
