//
//  F4SArrangeTableViewController.swift
//  DocumentCapture
//
//  Created by Keith Dev on 09/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

protocol F4SArrangeTableViewControllerDelegate : class {
    func arranger(_ arranger: F4SArrangeTableViewController, didSelectRowAtIndexPath:IndexPath)
    
    func arrangerCountChanged(_ arranger:  F4SArrangeTableViewController, count: Int)
}

class F4SArrangeTableViewController: F4SDocumentTableViewController {
    
    weak var delegate: F4SArrangeTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isEditing = false
    }
    
    override func configure(_ cell: UITableViewCell, with page: F4SDocumentPage) {
        guard let cell = cell as? F4SArrangeTableViewCell else {
            return
        }
        cell.pageImageView.image = page.image
        tableView.separatorStyle = .singleLine
    }
    
    override func processModelNotification(changeType: DocumentChange, userInfo: [AnyHashable : Any]) {
        if changeType == .documentModelDidRearrangePages {
            // Ignore rearranges because they were triggered by this controller and we don't want to do things twice
            return
        }
        super.processModelNotification(changeType: changeType, userInfo: userInfo)
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            let count = strongSelf.documentModel.pageCount
            strongSelf.tableView.separatorStyle = count == 0 ? .none : .singleLine
            strongSelf.delegate?.arrangerCountChanged(strongSelf, count: count)
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        documentModel.rearrange(fromIndex: fromIndexPath.row, toIndex: to.row)
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.arranger(self, didSelectRowAtIndexPath: indexPath)
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
}
