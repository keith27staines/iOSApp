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
    var messageList: [Message] = []
    var cannedResponses: F4SCannedResponses? = nil
    var action: F4SAction? = nil {
        didSet {
            loadChatData()
            guard let action = self.action else {
                return
            }
            actionButton.setTitle(action.actionType.actionTitle, for: .normal)
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
        getMessages(completion: { [weak self] error in
            DispatchQueue.main.async {
                guard let strongSelf = self else {
                    return
                }
                strongSelf.loadChatData()
                MessageHandler.sharedInstance.hideLoadingOverlay()
            }
        })
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
            switch action.actionType {
            case .uploadDocuments:
                performSegue(withIdentifier: "uploadDocumentsBLRequest", sender: self)
            }
            
        } catch {
            // Handle exception
            print(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueName: String = segue.identifier!
        if segueName == "toMessage" {
            self.messageController = segue.destination as? MessageViewController
            return
        }
        if segueName == "uploadDocumentsBLRequest" {
            guard let vc = segue.destination as? F4SUploadSpecifiedDocumentsViewController else { return }
            vc.companyName = company?.name ?? "this company"
            vc.action = action
            return
        }
    }
}

extension MessageContainerViewController {
    func getMessageAction(threadUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SAction?>) -> ()) {
        let actionService = F4SMessageActionService(threadUuid: threadUuid)
        actionService.getMessageAction { result in
            completion(result)
        }
    }
    
    func getCannedResponses(threadUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SCannedResponses>) -> ()) {
        let cannedResponseService = F4SCannedMessageResponsesService(threadUuid: threadUuid)
        cannedResponseService.getPermittedResponses { result in
            completion(result)
        }
    }
}

extension MessageContainerViewController {
    func getMessages(completion: @escaping (Error?) -> ()) {
        guard let threadUuid = self.threadUuid else { return }
        
        if let reachability = Reachability() {
            if !reachability.isReachableByAnyMeans {
                MessageHandler.sharedInstance.display("No Internet Connection.", parentCtrl: self)
                return
            }
        }
        
        MessageHandler.sharedInstance.showLoadingOverlay(self.view)
        MessageService.sharedInstance.getMessagesInThread(threadUuid: threadUuid, getCompleted: {
            [weak self] _, result in
            
            guard let strongSelf = self else {
                return
            }

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
            
        })
        
        getMessageAction(threadUuid: threadUuid, completion: { [weak self] actionResult in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                switch actionResult {
                case .error(let error):
                    completion(error)
                case .success(let action):
                    if let action = action {
                        self?.action = action
                        completion(nil)
                    } else {
                        strongSelf.getCannedResponses(threadUuid: threadUuid, completion: { cannedResponsesResult in
                            switch cannedResponsesResult {
                            case .error(let error):
                                completion(error)
                            case .success(let cannedResponses):
                                strongSelf.cannedResponses = cannedResponses
                            }
                        })
                    }
                }
            }
        })
        
    }
    
    func loadChatData() {
        if action != nil {
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
        let message = Message(uuid: response.uuid, content: response.value, sender: self.currentUserUuid)
        self.messageController?.didAnswer(message: message)
        
        MessageService.sharedInstance.sendMessageForThread(responseUuid: response.uuid,
                                                           threadUuid: threadUuid,
                                                           putCompleted: { [weak self] _, result in
            guard let strongSelf = self else { return }
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
                        strongSelf.cannedResponses = nil
                        strongSelf.answersHeight.constant = 0
                        strongSelf.view.layoutIfNeeded()
                    }
                }
            }
        })
        
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
            CustomNavigationHelper.sharedInstance.presentContentViewController(navCtrl: navigCtrl, contentType: ContentType.company, url: companyUrl)
        }
    }
}
