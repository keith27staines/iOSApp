//
//  MessageContainerViewController.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 2/13/17.
//  Copyright © 2017 freshbyte. All rights reserved.
//

import Foundation
import UIKit
import Reachability
import KeychainSwift

class MessageContainerViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var answersView: UIView!
    @IBOutlet weak var answersHeight: NSLayoutConstraint!
    var messageController: MessageViewController?
    var threadUuid: String?
    var company: Company?
    var placements: [TimelinePlacement] = []
    var companies: [Company] = []
    var messageList: [Message] = []
    var messageOptionList: [MessageOption] = []
    var currentUserUuid: String = ""
    var messageOptionsView: MessageOptionsView?
    var shouldLoadOptions: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        getMessages()
        let keychain = KeychainSwift()
        if let userUuid = keychain.get(UserDefaultsKeys.userUuid) {
            self.currentUserUuid = userUuid
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addAnswersView()
        setNavigationBar()
        
        UIApplication.shared.statusBarStyle = .lightContent
        self.evo_drawerController?.openDrawerGestureModeMask = .init(rawValue: 0)
        
        self.tabBarController?.tabBar.isTranslucent = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.evo_drawerController?.openDrawerGestureModeMask = .all
        
        self.tabBarController?.tabBar.isTranslucent = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueName: String = segue.identifier!
        if segueName == "toMessage"
        {
            self.messageController = segue.destination as? MessageViewController
        }
    }
}

extension MessageContainerViewController {
    func getMessages() {
        if let reachability = Reachability() {
            if !reachability.isReachableByAnyMeans {
                MessageHandler.sharedInstance.display("No Internet Connection.", parentCtrl: self)
                return
            }
        }
        
        if let uuid = self.threadUuid {
            var count = 0
            MessageHandler.sharedInstance.showLoadingOverlay(self.view)
            MessageService.sharedInstance.getMessagesInThread(threadUuid: uuid, getCompleted: {
                [weak self]
                _, result in
                guard let strongSelf = self else {
                    return
                }
                count += 1
                switch result
                {
                case let .error(error):
                    log.debug(error)
                    break
                case let .deffinedError(error):
                    log.debug(error)
                    break
                case let .value(boxed):
                    strongSelf.messageList = boxed.value
                    break
                }
                if count == 2 {
                    strongSelf.loadChatData()
                    MessageHandler.sharedInstance.hideLoadingOverlay()
                }
            })
            
            MessageService.sharedInstance.getOptionsForThread(threadUuid: uuid, getOptionsCompleted: {
                [weak self]
                _, result in
                guard let strongSelf = self else {
                    return
                }
                count += 1
                switch result
                {
                case let .error(error):
                    log.debug(error)
                    break
                case let .deffinedError(error):
                    log.debug(error)
                    break
                case let .value(boxed):
                    strongSelf.messageOptionList = boxed.value
                    break
                }
                if count == 2 {
                    strongSelf.loadChatData()
                    MessageHandler.sharedInstance.hideLoadingOverlay()
                }
            })
        }
    }
    
    func loadChatData() {
        
        guard let meesageOptionFooter = self.messageOptionsView else {
            return
        }
        
        if self.messageOptionList.count > 0 {
            meesageOptionFooter.loadMessageOptions(options: self.messageOptionList, parentController: self)
            self.answersHeight.constant = MessageOptionHelper.sharedInstance.getFooterSize(options: self.messageOptionList).height
            self.view.layoutIfNeeded()
        } else {
            self.answersHeight.constant = 0
            self.view.layoutIfNeeded()
        }
        
        self.messageController?.loadChatData(messageList: self.messageList)
    }
    
    func addAnswersView() {
        self.messageOptionsView = MessageOptionsView(frame: self.answersView.bounds)
        self.answersView.addSubview(self.messageOptionsView!)
    }
    
    func didSelectAnswer(index: Int) {
        guard let uuid = self.threadUuid else {
            return
        }
        var isDoneRemove: Bool = false
        var isDoneGet: Bool = false
        let messageToSend = messageOptionList[index]
        let message = Message(uuid: messageToSend.uuid, content: self.messageOptionList[index].value, sender: self.currentUserUuid)
        self.messageController?.didAnswer(message: message)
        self.messageOptionList = []
        
        MessageService.sharedInstance.sendMessageForThread(responseUuid: messageToSend.uuid, threadUuid: uuid, putCompleted: {
            [weak self]
            _, result in
            guard let strongSelf = self else {
                return
            }
            switch result
            {
            case .error:
                break
            case .deffinedError:
                break
            case let .value(boxed):
                DispatchQueue.main.async {
                    isDoneGet = true
                    if let lastMessage = boxed.value.last {
                        strongSelf.messageList.append(lastMessage)
                        strongSelf.messageController?.addMessage(message: lastMessage)
                    }
                    if isDoneRemove && isDoneGet {
                        self?.messageOptionList = []
                        self?.answersHeight.constant = 0
                        self?.view.layoutIfNeeded()
                    }
                }
            }
        })
        
        self.messageOptionsView?.removeOptions(completed: {
            isDoneRemove = true
            if isDoneRemove && isDoneGet {
                self.messageOptionList = []
                self.answersHeight.constant = 0
                self.view.layoutIfNeeded()
            }
        })
    }
    
    func showMessageWithThread(threadUuid: String) {
        if let placement = self.placements.filter({ $0.threadUuid == threadUuid }).first, let company = self.companies.filter({ $0.uuid == placement.companyUuid.replacingOccurrences(of: "-", with: "") }).first {
            CustomNavigationHelper.sharedInstance.moveToMessageController(parentCtrl: self, threadUuid: threadUuid, company: company, placements: self.placements, companies: self.companies)
        }
    }
}

// MARK: - navigation
extension MessageContainerViewController {
    func setNavigationBar() {
        navigationController?.navigationBar.barTintColor = UIColor(netHex: Colors.azure)
        navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        let backButton = UIBarButtonItem(image: UIImage(named: "Back"), style: UIBarButtonItemStyle.done, target: self, action: #selector(backButtonTouched))
        backButton.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = backButton
        
        let showCompanyButton = UIBarButtonItem(image: UIImage(named: "information"), style: UIBarButtonItemStyle.done, target: self, action: #selector(showCompanyDetailsView))
        navigationItem.rightBarButtonItem = showCompanyButton
        navigationItem.title = self.company?.name
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    @objc func backButtonTouched() {
        if let viewCtrls = self.navigationController?.viewControllers {
            for viewCtrl in viewCtrls {
                if viewCtrl is TimelineViewController {
                    _ = self.navigationController?.popToViewController(viewCtrl, animated: true)
                    break
                }
            }
        }
    }
    
    @objc func showCompanyDetailsView() {
        if let companyUrl = self.company?.companyUrl, let navigCtrl = self.navigationController {
            CustomNavigationHelper.sharedInstance.moveToContentViewController(navCtrl: navigCtrl, contentType: ContentType.company, url: companyUrl)
        }
    }
}
