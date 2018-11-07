//
//  F4SDocumentTableViewController.swift
//  DocumentCapture
//
//  Created by Keith Dev on 09/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class F4SDocumentTableViewController: UITableViewController {
    
    var documentModel: F4SMultiPageDocument = F4SMultiPageDocument()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForNotificationsFromModel()
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func registerForNotificationsFromModel() {
        let center = NotificationCenter.default
        for name in F4SMultiPageDocument.notificationNames() {
            center.addObserver(forName: name, object: nil, queue: nil) { [weak self]
                (notification) in
                guard
                    let strongSelf = self,
                    let changeType = DocumentChange(rawValue: notification.name.rawValue),
                    let userInfo = notification.userInfo
                    else { return }
                DispatchQueue.main.async {
                    strongSelf.processModelNotification(changeType: changeType, userInfo: userInfo)
                }
            }
        }
    }
    
    func processModelNotification(changeType: DocumentChange, userInfo: [AnyHashable:Any]) {
        tableView.reloadData()
//        switch changeType {
//        case .documentModelDidReplacePage:
//            guard let row = userInfo["index"] as? Int else { return }
//            let indexPath = IndexPath(row: row, section: 0)
//            tableView.reloadRows(at: [indexPath], with: .automatic)
//        case .documentModelDidRemovePage:
//            guard let row = userInfo["index"] as? Int else { return }
//            let indexPath = IndexPath(row: row, section: 0)
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//        case .documentModelDidInsertPage:
//            guard let row = userInfo["index"] as? Int else { return }
//            let indexPath = IndexPath(row: row, section: 0)
//            tableView.insertRows(at: [indexPath], with: .automatic)
//        case .documentModelDidRearrangePages:
//            guard
//                let fromRow = userInfo["fromIndex"] as? Int,
//                let toRow = userInfo["toIndex"] as? Int
//                else { return }
//            let fromPath = IndexPath(row: fromRow, section: 0)
//            let toPath = IndexPath(row: toRow, section: 0)
//            tableView.moveRow(at: fromPath, to: toPath)
//        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentModel.pageCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let page = documentModel.pageAtIndex(indexPath.row)
        configure(cell, with: page)
        return cell
    }
    
    /// subclasses MUST override
    func configure(_ cell: UITableViewCell, with page: F4SDocumentPage) {
        fatalError()
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
    
}
