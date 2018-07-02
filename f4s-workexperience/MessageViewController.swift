//
//  MessageViewController.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 1/4/17.
//  Copyright © 2017 freshbyte. All rights reserved.
//

import Foundation
import UIKit
import JSQMessagesViewController
import KeychainSwift
import Reachability

class MessageViewController: JSQMessagesViewController {
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor(netHex: Colors.messageIncoming))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor(netHex: Colors.messageOutgoing))
    var chatMessages: [JSQMessage] = []
    var messageList: [F4SMessage] = []
    var currentUserUuid: String = ""
    var selectedIndex: Int = 0

    let StatusCollectionViewCellIdentifier = "StatusCollectionViewCell"
    var messageDateTimeFormatter: DateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.inputToolbar.isHidden = true
        self.collectionView?.register(StatusCollectionViewCell.self, forCellWithReuseIdentifier: StatusCollectionViewCellIdentifier)
        self.collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 14, height: 0)
        self.collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 14, height: 0)
        self.collectionView?.collectionViewLayout.messageBubbleFont = UIFont.f4sSystemFont(size: Style.smallerMediumTextSize, weight: UIFont.Weight.regular)
        self.collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.view.layoutIfNeeded()

        let keychain = KeychainSwift()
        if let userUuid = keychain.get(UserDefaultsKeys.userUuid) {
            self.currentUserUuid = userUuid
        }
        self.messageDateTimeFormatter.dateFormat = "dd MMM yyyy HH:mm"
    }
}

// MARK: - data source
extension MessageViewController {
    override func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.chatMessages.count
    }

    override func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        return self.chatMessages[indexPath.row]
    }

    override func collectionView(_: JSQMessagesCollectionView, didDeleteMessageAt indexPath: IndexPath) {
        self.chatMessages.remove(at: indexPath.row)
    }

    override func collectionView(_: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
        switch chatMessages[indexPath.row].senderId
        {
        case self.currentUserUuid:
            return self.outgoingBubble
        default:
            return self.incomingBubble
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.messageList.count > indexPath.row && self.messageList[indexPath.row].sender.isEmpty {
            guard let statusCell = collectionView.dequeueReusableCell(withReuseIdentifier: StatusCollectionViewCellIdentifier, for: indexPath) as? StatusCollectionViewCell else {
                return UICollectionViewCell()
            }
            statusCell.statusLabel.textColor = UIColor(netHex: Colors.black)
            statusCell.statusLabel.font = UIFont.f4sSystemFont(size: Style.smallTextSize, weight: UIFont.Weight.regular)
            statusCell.statusLabel.text = self.chatMessages[indexPath.row].text
            return statusCell
        }
        guard let cell: JSQMessagesCollectionViewCell = super.collectionView(collectionView, cellForItemAt: indexPath) as? JSQMessagesCollectionViewCell else {
            return UICollectionViewCell()
        }
        // cell.textView?.dataDetectorTypes = .init(rawValue: 0)
        switch chatMessages[indexPath.row].senderId
        {
        case self.currentUserUuid:
            cell.textView?.textColor = UIColor(netHex: Colors.white)
            cell.textView?.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor(netHex: Colors.white), NSAttributedStringKey.underlineStyle.rawValue: NSUnderlineStyle.styleSingle.rawValue]
        default:
            cell.textView?.textColor = UIColor(netHex: Colors.black)
            cell.textView?.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor(netHex: Colors.black), NSAttributedStringKey.underlineStyle.rawValue: NSUnderlineStyle.styleSingle.rawValue]
        }
        cell.textView?.font = UIFont.f4sSystemFont(size: Style.smallerMediumTextSize, weight: UIFont.Weight.regular)

        if self.selectedIndex >= 0 && indexPath.row == self.selectedIndex {
            switch chatMessages[indexPath.row].senderId
            {
            case self.currentUserUuid:
                // outgoing bubble -> right inset
                cell.cellBottomLabel?.textInsets = UIEdgeInsetsMake(0, 0, 0, 24)
                break
            default:
                // incomming bubble -> left inset
                cell.cellBottomLabel?.textInsets = UIEdgeInsetsMake(0, 24, 0, 0)
                break
            }
        } else {
            cell.cellBottomLabel?.textInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        }
        return cell
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellBottomLabelAt indexPath: IndexPath) -> NSAttributedString? {
        if self.selectedIndex >= 0 && indexPath.row == self.selectedIndex && self.messageList.count > indexPath.row {
            if let messageDate = messageList[indexPath.row].dateTime {
                return NSAttributedString(string: self.messageDateTimeFormatter.string(from:messageDate))
            } else {
                return NSAttributedString(string: "unknown date")
            }

        }
        return NSAttributedString(string: "")
    }

    override func collectionView(_: JSQMessagesCollectionView, layout _: JSQMessagesCollectionViewFlowLayout, heightForCellBottomLabelAt indexPath: IndexPath) -> CGFloat {
        if self.selectedIndex >= 0 && indexPath.row == self.selectedIndex && self.messageList.count > indexPath.row{
            return 20
        } else {
            return 0
        }
    }

    override func collectionView(_: JSQMessagesCollectionView, layout _: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row > 0 {
            if self.chatMessages[indexPath.row].senderId == self.chatMessages[indexPath.row - 1].senderId {
                // same type of message
                return 5
            } else {
                // different type of message
                // increase size
                return 15
            }
        }
        return 5
    }

    override func collectionView(_: JSQMessagesCollectionView, didTapCellAt indexPath: IndexPath, touchLocation _: CGPoint) {
        self.selectedIndex = indexPath.row
        self.collectionView?.reloadData()
    }

    override func collectionView(_: JSQMessagesCollectionView, didTapMessageBubbleAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        self.collectionView?.reloadData()
    }
}

// MARK: - calls
extension MessageViewController {

    func loadChatData(messageList: [F4SMessage]) {
        self.chatMessages.removeAll()
        self.messageList = messageList
        self.selectedIndex = self.messageList.count - 1
        for message in self.messageList {
            self.chatMessages.append(JSQMessage(senderId: message.sender, displayName: message.sender, text: message.content))
        }
        self.finishReceivingMessage()
        self.scrollToBottom(animated: true)
    }
    
    func didAnswer(message: F4SMessage) {
        self.chatMessages.append(JSQMessage(senderId: message.sender, displayName: message.sender, text: message.content))
        self.finishSendingMessage()
        self.scrollToBottom(animated: true)
    }
    
    func addMessage(message: F4SMessage) {
        self.messageList.append(message)
    }
}

// MARK: - helpers
extension MessageViewController {
    override func senderId() -> String {
        return self.currentUserUuid
    }

    override func senderDisplayName() -> String {
        return self.currentUserUuid
    }
}
