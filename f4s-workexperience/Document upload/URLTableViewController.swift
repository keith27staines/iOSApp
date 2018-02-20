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
    
    var bigRowIndexPath: IndexPath = IndexPath(row:-1,section:0)
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelection = false
        tableView.estimatedRowHeight = 40.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func createNewLink() {
        _ = documentUrlModel.createNewLink(includeInApplication: false)
        let indexPath = IndexPath(row: documentUrlModel.numberOfRows(for: 0) - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
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
        cell.documentUrlDescriptor = documentUrlModel.urlDescriptors[indexPath.row]
        cell.deleteButtonWasPressed = deleteUrlForCell
        if indexPath == bigRowIndexPath {
            cell.label.numberOfLines = 0
            cell.label.lineBreakMode = .byCharWrapping
        } else {
            cell.label.numberOfLines = 1
            cell.label.lineBreakMode = .byTruncatingHead
        }
        return cell
    }
    
    func deleteUrlForCell(cell: UrlTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        var urlDescriptor = documentUrlModel.urlDescriptors[indexPath.row]
        urlDescriptor.urlString = ""
        bigRowIndexPath = IndexPath(row: -1, section: 0)
        documentUrlModel.setDescriptor(urlDescriptor, at: indexPath.row)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? UrlTableViewCell else { return }
        var urlDescriptor = documentUrlModel.urlDescriptors[indexPath.row]
        defer {
            // Before we finish, we resize the height of the selected cell and the deselected cell
            let oldBigRowIndexPath = bigRowIndexPath
            bigRowIndexPath = indexPath
            if oldBigRowIndexPath != bigRowIndexPath {
                tableView.reloadRows(at: [bigRowIndexPath,oldBigRowIndexPath], with: .automatic)
            }
        }
        guard !urlDescriptor.isValidUrl else {
            return
        }
        let pasteText = UIPasteboard.general.string ?? ""
        if URL(string: pasteText) != nil {
            urlDescriptor.urlString = pasteText
            documentUrlModel.setDescriptor(urlDescriptor, at: indexPath.row)
            cell.documentUrlDescriptor = urlDescriptor
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cell = tableView.cellForRow(at: indexPath) as? UrlTableViewCell else {
            return 40.0
        }
        let smallHeight = cell.requiredHeight(numberOfLines: 1)
        let bigHeight = cell.requiredHeight(numberOfLines: 0)
        return indexPath == bigRowIndexPath ? bigHeight : smallHeight
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            documentUrlModel.deleteDescriptor(index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */

}
