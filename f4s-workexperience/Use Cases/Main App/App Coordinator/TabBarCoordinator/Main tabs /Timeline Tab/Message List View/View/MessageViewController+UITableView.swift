//
//  MessageViewController+UITableView.swift
//
//  Created by Keith Staines on 24/11/2018.
//  Copyright © 2018 Keith Staines. All rights reserved.
//

import UIKit
import WorkfinderUI

extension MessageViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return messagesModel.numberOfSections
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesModel.numberOfRowsInSection(section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messagesModel.messageForIndexPath(indexPath)
        let cell: MessageTableViewCell
        if message.senderId == messagesModel.outgoingSenderId {
            cell = tableView.dequeueReusableCell(withIdentifier: OutgoingMessageTableViewCell.reuseIdentifier) as! MessageTableViewCell
            cell.configureWith(backgroundColor: outgoingMessageBackgroundColor, textColor: outgoingMessageTextColor)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: IncomingMessageTableViewCell.reuseIdentifier) as! MessageTableViewCell
            cell.configureWith(backgroundColor: incomingMessageBackgroundColor, textColor: incomingMessageTextColor)
        }
        cell.configureWith(message)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
