import UIKit
import Reachability
import Analytics
import WorkfinderCommon
import WorkfinderServices
import WorkfinderUI
import WorkfinderAcceptUseCase

class MessageContainerViewController: UIViewController {
    
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var actionButtonHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var answersView: UIView!
    @IBOutlet weak var answersHeight: NSLayoutConstraint!
    
    @IBAction func unwindToMessageContainer(segue: UIStoryboardSegue) {
    }
    
    weak var coordinator: TimelineCoordinator?
    var messageController: MessageViewController?
    var threadUuid: String?
    var company: Company?
    var placements: [F4STimelinePlacement] = []
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

    var placement: F4STimelinePlacement? {
        return placements.first(where: { (placement) -> Bool in
            placement.companyUuid?.dehyphenated == self.company?.uuid.dehyphenated && threadUuid?.dehyphenated == placement.threadUuid?.dehyphenated
        })
    }
    
    @IBOutlet weak var subjectLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let userUuid = F4SUser().uuid {
            self.currentUserUuid = userUuid
        }
        actionButtonHeightConstraint.constant = 0.0
        actionButton.isEnabled = false
        Skinner().apply(buttonSkin: skin?.primaryButtonSkin, to: actionButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addAnswersView()
        setNavigationBar()
        subjectLabel.text = company?.name ?? "Workfinder"
        self.evo_drawerController?.openDrawerGestureModeMask = .init(rawValue: 0)
        self.tabBarController?.tabBar.isTranslucent = true
        self.tabBarController?.tabBar.isHidden = true
        guard let threadUuid = self.threadUuid else { return }
        loadModel(threadUuid: threadUuid)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var modelBuilder: F4SMessageModelBuilder? = nil
    
    func loadModel(threadUuid: F4SUUID) {
        sharedUserMessageHandler.showLoadingOverlay(self.view)
        modelBuilder = F4SMessageModelBuilder(threadUuid: threadUuid)
        modelBuilder!.build(threadUuid: threadUuid) { [weak self] (result) in
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
                sharedUserMessageHandler.hideLoadingOverlay()
            }
        }
    }
    
    func networkErrorHandler(error: F4SNetworkError, retryHandler: @escaping ()->()) {
        sharedUserMessageHandler.display(error, parentCtrl: self, cancelHandler: {
            
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
        do {
            try F4SActionValidator.validate(action: action)
            let actionType = action.actionType!
            switch actionType {
            case .uploadDocuments:
                coordinator?.showAddDocuments(placement: placement, company: company, action: action)
                
            case .viewOffer:
                sharedUserMessageHandler.showLoadingOverlay(self.view)
                prepareAcceptOffer { [weak self] (error, context) in
                    guard let strongSelf = self else { return }
                    if let error = error {
                        sharedUserMessageHandler.display(error, parentCtrl: strongSelf, cancelHandler: nil, retryHandler: nil)
                        globalLog.error(error)
                    } else {
                        sharedUserMessageHandler.hideLoadingOverlay()
                        strongSelf.acceptContext = context
                        strongSelf.coordinator?.showAcceptOffer(acceptContext: context)
                    }
                }
                
            case .viewCompanyExternalApplication:
                let urlString = action.argument(name: F4SActionArgumentName.externalWebsite)?.value.first
                coordinator?.showExternalCompanySite(urlString: urlString, acceptContext: acceptContext)
            }
        } catch {
            globalLog.error(error)
        }
    }
    
    func prepareAcceptOffer(completion: @escaping (F4SNetworkError?, AcceptOfferContext?) -> ()) {
        guard let placementUuid = placement?.placementUuid else { return }
        loadPlacementOffer(uuid: placementUuid) { [weak self] (networkResult) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                sharedUserMessageHandler.hideLoadingOverlay()
                switch networkResult {
                case .error(let error):
                    if error.retry {
                        sharedUserMessageHandler.display(error, parentCtrl: strongSelf, cancelHandler: {
                            return
                        }, retryHandler: {
                            strongSelf.prepareAcceptOffer(completion: completion)
                        })
                    } else {
                        completion(error, nil)
                    }
                    
                case .success(var placement):
                    
                    if placement.duration == nil {
                        placement.duration = placement.availabilityPeriods?.first
                    }
                    
                    let user = F4SUser()
                    if let url = NSURL(string: strongSelf.company?.logoUrl ?? "") {
                        F4SImageService.sharedInstance.getImage(url: url, completion: { [weak self] image in
                            guard
                                let strongSelf = self,
                                let roleUuid = placement.roleUuid else { return }
                            
                            let companyService = F4SCompanyService()
                            let roleService = F4SRoleService()
                            let companyUuid = strongSelf.company!.uuid
                            roleService.getRoleForCompany(companyUuid: companyUuid, roleUuid: roleUuid, completion: { (networkResult) in
                                DispatchQueue.main.async {
                                    switch networkResult {
                                    case .error(let error):
                                        completion(error, nil)
                                    case .success(let role):
                                        companyService.getCompany(uuid: companyUuid, completion: { (result) in
                                            DispatchQueue.main.async {
                                                switch result {
                                                case .error(let error):
                                                    completion(error, nil)
                                                case .success(let companyJson):
                                                    let companyViewData = CompanyViewData(company: strongSelf.company!)
                                                    let context = AcceptOfferContext(user: user, company: companyViewData, companyJson: companyJson, logo: image, placement: placement, role: role)
                                                    completion(nil, context)
                                                }
                                            }
                                        })
                                    }
                                }
                            })
                        })
                    }
                }
            }
        }
    }
    
    func loadPlacementOffer(uuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4STimelinePlacement>) -> () ) {
        let service = F4SPlacementService()
        service.getPlacementOffer(uuid: uuid) { (networkResult) in
            completion(networkResult)
        }
    }
    
    internal var acceptContext: AcceptOfferContext? = nil
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        assert(segue.identifier == "toMessage", "Unexpected segue from MessageContainerViewController")
        messageController = (segue.destination as! MessageViewController)
        configureMessageController()
    }
    
    func configureMessageController() {
        messageController?.outgoingMessageTextColor = UIColor.blue
        messageController?.outgoingMessageBackgroundColor = UIColor(netHex: Colors.messageOutgoing)
        messageController?.outgoingMessageTextColor = UIColor(netHex:Colors.messageOutgoingText)
        messageController?.incomingMessageBackgroundColor = UIColor(netHex:Colors.messageIncoming)
        messageController?.incomingMessageTextColor = UIColor(netHex:Colors.messageIncomingText)
    }
}

extension MessageContainerViewController {

    func loadChatData() {
         actionButtonHeightConstraint.constant = 0
        // Note that the following `action?.actionType != nil` check is not directly against action but against actionType for a good reason. The api returns an action structure with all fields set to null when there is no data
        if action?.actionType != nil {
            actionButtonHeightConstraint.constant = 60
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] in
                self?.view.layoutIfNeeded()
            }) { [weak self] (success) in
                self?.actionButton.isEnabled = true
            }
            self.messageController?.reloadWithMessages(outgoingSenderId: currentUserUuid, messages: self.messageList)
            return
        }
        
        guard let meesageOptionFooter = self.messageOptionsView else { return }
        
        if let cannedResponses = self.cannedResponses, cannedResponses.options.count > 0 {
            meesageOptionFooter.loadMessageOptions(options: cannedResponses.options, parentController: self)
            self.answersHeight.constant = MessageOptionHelper.sharedInstance.getFooterSize(options: cannedResponses.options).height
            self.view.layoutIfNeeded()
            return
        } else {
            self.answersHeight.constant = 0
            self.view.layoutIfNeeded()
        }
        self.messageController?.reloadWithMessages(outgoingSenderId: currentUserUuid, messages: self.messageList)
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
                        strongSelf.messageController?.insertMessage(lastMessage)
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
        if let placement = self.placements.filter({ $0.threadUuid == threadUuid }).first, let company = self.companies.filter({ $0.uuid == placement.companyUuid!.dehyphenated }).first {
            coordinator?.showMessageController(parentCtrl: self, threadUuid: threadUuid, company: company, placements: self.placements, companies: self.companies)
        }
    }
}

// MARK: - navigation
extension MessageContainerViewController {
    func setNavigationBar() {
        let showCompanyButton = UIBarButtonItem(title: NSLocalizedString("Company", comment: "Title of a button that links to a company info page"), style: UIBarButtonItem.Style.done, target: self, action: #selector(showCompanyDetailsView))
        navigationItem.rightBarButtonItem = showCompanyButton
        navigationItem.title = "Messages"
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        styleNavigationController()
    }
    
    @objc func showCompanyDetailsView() {
        guard let company = self.company else { return }
        coordinator?.showCompanyDetails(parentCtrl: self, company: company)
    }
}
