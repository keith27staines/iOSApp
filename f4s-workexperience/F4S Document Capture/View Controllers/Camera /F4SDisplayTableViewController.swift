//
//  F4SDisplayTableViewController.swift
//  DocumentCapture
//
//  Created by Keith Dev on 09/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit
import WorkfinderUI

class F4SDisplayTableViewController: F4SDocumentTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
    }
    
    override func configure(_ cell: UITableViewCell, with page: F4SDocumentPage) {
        guard let cell = cell as? F4SDisplayTableViewCell else { return }
        cell.page = page
        cell.delegate = self
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    override func processModelNotification(changeType: DocumentChange, userInfo: [AnyHashable : Any]) {
        
        if multiPageModel.pageCount == 0 {
            tableView.separatorStyle = .none
        } else {
            tableView.separatorStyle = .singleLine
        }
        
        super.processModelNotification(changeType: changeType, userInfo: userInfo)

        if changeType == .documentModelDidInsertPage {
            guard let index = userInfo["index"] as? Int else { return }
            let indexPath = IndexPath(row: index, section: 0)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }

    }
}

extension F4SDisplayTableViewController : F4SDisplayTableViewCellDelegate {
    func deletePage(_ page: F4SDocumentPage) {
        multiPageModel.remove(page)
    }
    
//    func retakePage(_ page: F4SDocumentPage) {
//
//    }
}
