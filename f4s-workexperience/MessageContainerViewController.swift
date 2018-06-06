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
    
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var actionButtonHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var answersView: UIView!
    @IBOutlet weak var answersHeight: NSLayoutConstraint!
    var messageController: MessageViewController?
    var threadUuid: String?
    var company: Company?
    var placements: [TimelinePlacement] = []
    var companies: [Company] = []
    var messageList: [F4SMessage] = []
    var cannedResponses: F4SCannedResponses? = nil
    var action: F4SAction? = nil {
        didSet {
            loadChatData()
            guard let title = self.action?.actionType?.actionTitle else {
                return
            }
            actionButton.setTitle(title, for: .normal)
        }
    }
    var currentUserUuid: String = ""
    var messageOptionsView: MessageOptionsView?
    var shouldLoadOptions: Bool = true
    
    @IBOutlet weak var subjectLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        let keychain = KeychainSwift()
        if let userUuid = keychain.get(UserDefaultsKeys.userUuid) {
            self.currentUserUuid = userUuid
        }
        actionButtonHeightConstraint.constant = 0.0
        actionButton.isEnabled = false
        F4SButtonStyler.apply(style: .primary, button: actionButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addAnswersView()
        setNavigationBar()
        subjectLabel.text = company?.name ?? "Workfinder"
        
        UIApplication.shared.statusBarStyle = .lightContent
        self.evo_drawerController?.openDrawerGestureModeMask = .init(rawValue: 0)
        
        self.tabBarController?.tabBar.isTranslucent = true
        self.tabBarController?.tabBar.isHidden = true
        guard let threadUuid = self.threadUuid else { return }
        loadModel(threadUuid: threadUuid)
    }
    
    func loadModel(threadUuid: F4SUUID) {
        MessageHandler.sharedInstance.showLoadingOverlay(self.view)
        let messagesModel = F4SMessagesModel(threadUuid: threadUuid)
        messagesModel.build(threadUuid: threadUuid) { [weak self] (result) in
            DispatchQueue.main.async {
                guard let strongSelf = self else { return }
                switch result {
                case .error(let error):
                    strongSelf.networkErrorHandler(error: error, retryHandler: {
                        strongSelf.loadModel(threadUuid: threadUuid)
                    })
                case .success(let messagesModel):
                    strongSelf.messageList = messagesModel.messages ?? []
                    strongSelf.action = messagesModel.action
                    strongSelf.cannedResponses = messagesModel.cannedResponses
                }
                strongSelf.loadChatData()
                MessageHandler.sharedInstance.hideLoadingOverlay()
            }
        }
    }
    
    func networkErrorHandler(error: F4SNetworkError, retryHandler: @escaping ()->()) {
        MessageHandler.sharedInstance.display(error, parentCtrl: self, cancelHandler: {
            
        }, retryHandler: retryHandler)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.evo_drawerController?.openDrawerGestureModeMask = .all
        
        self.tabBarController?.tabBar.isTranslucent = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func actionButtonTapped(_ sender: Any) {
        guard let action = action else { return }
        actionButtonHeightConstraint.constant = 0
        actionButton.isEnabled = false
        do {
            try F4SActionValidator.validate(action: action)
            let actionType = action.actionType!
            switch action.actionType! {
            case .uploadDocuments:
                performSegue(withIdentifier: actionType.rawValue, sender: self)
            }
        } catch {
            log.error(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueName: String = segue.identifier!
        if segueName == "toMessage" {
            self.messageController = segue.destination as? MessageViewController
            return
        }
        if segueName == "upload_documents" {
            guard let vc = segue.destination as? F4SUploadSpecifiedDocumentsViewController else { return }
            vc.companyName = company?.name ?? "this company"
            vc.action = action
            return
        }
    }
}

extension MessageContainerViewController {

    func loadChatData() {
        // Note that following != nil check is not directly against action but against actionType. This is because the api returns an action structure with all fields set to null when there is no data
        if action?.actionType != nil {
            actionButtonHeightConstraint.constant = 60
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] in
                self?.view.layoutIfNeeded()
            }) { [weak self] (success) in
                self?.actionButton.isEnabled = true
            }
            self.messageController?.loadChatData(messageList: self.messageList)
            return
        }
        
        guard let meesageOptionFooter = self.messageOptionsView else {
            return
        }
        if let cannedResponses = self.cannedResponses, cannedResponses.options.count > 0 {
            meesageOptionFooter.loadMessageOptions(options: cannedResponses.options, parentController: self)
            self.answersHeight.constant = MessageOptionHelper.sharedInstance.getFooterSize(options: cannedResponses.options).height
            self.view.layoutIfNeeded()
            return
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
        guard let threadUuid = self.threadUuid, let response = cannedResponses?.options[index] else {
            return
        }
        var isDoneRemove: Bool = false
        var isDoneGet: Bool = false
        let message = F4SMessage(uuid: response.uuid, content: response.value, sender: self.currentUserUuid)
        self.messageController?.didAnswer(message: message)
        
        F4SMessageService(threadUuid: threadUuid).sendMessage(responseUuid: response.uuid) { (result) in
            switch result {
                
            case .error(_):
                break
            case .success(let messageList):
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    isDoneGet = true
                    if let lastMessage = messageList.messages.last {
                        strongSelf.messageList.append(lastMessage)
                        strongSelf.messageController?.addMessage(message: lastMessage)
                    }
                    if isDoneRemove && isDoneGet {
                        strongSelf.cannedResponses = nil
                        strongSelf.answersHeight.constant = 0
                        strongSelf.view.layoutIfNeeded()
                    }
                }
            }
        }
        
        self.messageOptionsView?.removeOptions(completed: {
            isDoneRemove = true
            if isDoneRemove && isDoneGet {
                self.cannedResponses = nil
                self.answersHeight.constant = 0
                self.view.layoutIfNeeded()
            }
        })
    }
    
    func showMessageWithThread(threadUuid: String) {
        if let placement = self.placements.filter({ $0.threadUuid == threadUuid }).first, let company = self.companies.filter({ $0.uuid == placement.companyUuid.replacingOccurrences(of: "-", with: "") }).first {
            CustomNavigationHelper.sharedInstance.pushMessageController(parentCtrl: self, threadUuid: threadUuid, company: company, placements: self.placements, companies: self.companies)
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
        navigationItem.title = "Messages"
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
            CustomNavigationHelper.sharedInstance.presentContentViewController(navCtrl: navigCtrl, contentType: F4SContentType.company, url: companyUrl)
        }
    }
}
