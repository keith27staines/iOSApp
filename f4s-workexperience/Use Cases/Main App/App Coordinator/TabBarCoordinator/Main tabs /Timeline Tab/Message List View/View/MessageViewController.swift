//
//  MessageViewController.swift
//
//  Created by Keith Staines on 23/11/2018.
//  Copyright © 2018 Keith Staines. All rights reserved.
//

import UIKit
import WorkfinderCommon

public class MessageViewController: UIViewController {
    
    internal var messagesModel: MessagesModel = MessagesModel(outgoingSenderId: "", messages: [])
    
    public var incomingMessageBackgroundColor = UIColor(white: 0.9, alpha: 1.0)
    public var incomingMessageTextColor = UIColor.black
    public var outgoingMessageBackgroundColor = UIColor.blue
    public var outgoingMessageTextColor = UIColor.white
    
    internal lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(IncomingMessageTableViewCell.self, forCellReuseIdentifier:  IncomingMessageTableViewCell.reuseIdentifier )
        tableView.register(OutgoingMessageTableViewCell.self, forCellReuseIdentifier: OutgoingMessageTableViewCell.reuseIdentifier )
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        return tableView
    }()
    
    public func insertMessage(_ message: MessageProtocol) {
        guard let indexPath = messagesModel.insertMessage(message) else { return }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    public func reloadWithMessages(outgoingSenderId: String, messages: [MessageProtocol]) {
        messagesModel = MessagesModel(outgoingSenderId: outgoingSenderId, messages: messages)
        tableView.reloadData()
        guard messages.count > 0 else { return }
        tableView.scrollToRow(at: IndexPath(row: messages.count-1, section: 0), at: UITableView.ScrollPosition.middle, animated: true)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.red
        configureViews()
    }
    
    private func configureViews() {
        view.addSubview(tableView)
        tableView.anchor(
            top: view.topAnchor,
            leading: view.leadingAnchor,
            bottom: view.bottomAnchor,
            trailing: view.trailingAnchor,
            padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
            size: CGSize.zero)
    }
}
