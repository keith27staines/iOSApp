import UIKit
import WorkfinderCommon
import WorkfinderServices
import WorkfinderUI
import WorkfinderAppLogic

class AcceptOfferViewController: UIViewController {
    @IBOutlet weak var offsetHeight: NSLayoutConstraint!
    
    @IBOutlet weak var introductionStack: UIStackView!
    @IBOutlet weak var headerHeight: NSLayoutConstraint!

    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    let initialHeaderHeight: CGFloat = 100.0
    
    @IBOutlet weak var pageHeaderView: F4SCompanyHeaderViewWithLogo!
    
    var placementInviteModel: F4SPlacementInviteModel!
    var accept: AcceptOfferContext!
    var companyDocumentsModel: F4SCompanyDocumentsModel!
    weak var coordinator: AcceptOfferCoordinator?
    
    var offerProcessor: F4SOfferProcessingServiceProtocol!
    var userMessageHandler = UserMessageHandler()
    var offerConfirmer: F4SOfferConfirmer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placementInviteModel = F4SPlacementInviteModel(context: accept)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(F4SInviteDetailCell.self, forCellReuseIdentifier: "detail")
        applyStyle()
        companyNameLabel.text = accept.company.companyName.stripCompanySuffix()
        pageHeaderView.icon = accept.companyLogo
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyStyle()
        self.tabBarController?.tabBar.isTranslucent = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        captureShareImage()
    }
    
    func captureShareImage() {
        guard accept.offerImage == nil else { return }
        let headerImage = pageHeaderView.snapshotToImage()
        let introImage = introductionStack.snapshotToImage()
        let tableImage = tableView.renderAllContentToImage()
        var totalHeight = headerImage.size.height
        totalHeight += introImage.size.height
        totalHeight += tableImage.size.height
        
        UIGraphicsBeginImageContext(CGSize(width: headerImage.size.width, height: totalHeight))
        var height: CGFloat = 0.0
        headerImage.draw(at: CGPoint(x: 0, y: height))
        height += headerImage.size.height
        introImage.draw(at: CGPoint(x: 0, y: height))
        height += introImage.size.height
        tableImage.draw(at: CGPoint(x: 0, y: height))
        height += tableImage.size.height
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        accept.offerImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let hoorayViewController = segue.destination as? F4SHoorayViewController {
            hoorayViewController.accept = accept
            hoorayViewController.coordinator = coordinator
            return
        }
        if let requestDocumentsViewController = segue.destination as? RequestBLProvideDocuments {
            requestDocumentsViewController.accept = accept
            requestDocumentsViewController.coordinator = coordinator
            requestDocumentsViewController.companyDocumentsModel = self.companyDocumentsModel
            requestDocumentsViewController.placementService = offerProcessor
            return
        }
    }
    
    func confirmOffer() {
        let offerConfirmer = F4SOfferConfirmer(
            messageHandler: userMessageHandler,
            placementService: offerProcessor,
            placement: accept.placement,
            sender: self)
        offerConfirmer.confirmOffer() { [weak self] in
            self?.performSegue(withIdentifier: "showHooray", sender: self)
        }
        self.offerConfirmer = offerConfirmer
    }
}

extension AcceptOfferViewController {
    func applyStyle() {
        pageHeaderView.backgroundColor = UIColor.white
        pageHeaderView.leftDrop = 1.0
        pageHeaderView.rightDrop = 0.1
        navigationItem.title = ""
        pageHeaderView.fillColor = splashColor
        styleNavigationController()
    }
}

// MARK:- UITableViewDatasource
extension AcceptOfferViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return placementInviteModel.numberOfSections() + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < placementInviteModel.numberOfSections() {
            // Most sections contain data as described by the model
            return placementInviteModel.numberOfRows(section)
        } else {
            // The very last section doesn't contain data from the model, it contains buttons to allow the user to accept or decline
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section < placementInviteModel.numberOfSections() {
            let inviteDetails = placementInviteModel.inviteDetailsForIndexPath(indexPath)
            if inviteDetails.requiresButtonAction {
                let cell = tableView.dequeueReusableCell(withIdentifier: "detailWithLink", for: indexPath) as! F4SInviteDetailLinkCell
                cell.buttonAction = { [weak self] cell in
                    guard let companyViewData = self?.accept?.company else { return }
                    self?.coordinator?.showCompanyDetail(companyViewData)
                }
                cell.detail = inviteDetails
                return cell
            }
            if inviteDetails.isEmail || inviteDetails.linkUrl != nil {
                let cell = tableView.dequeueReusableCell(withIdentifier: "detailWithLink", for: indexPath) as! F4SInviteDetailLinkCell
                cell.detail = inviteDetails
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "detail", for: indexPath) as! F4SInviteDetailCell
                cell.detail = inviteDetails
                return cell
            }

        } else {
            guard let buttonsCell = tableView.dequeueReusableCell(withIdentifier: "buttons") as? F4SInviteButtonsTableViewCell else {
                return UITableViewCell()
            }
            let workflowState = accept.placement.workflowState
            configureButtonCell(buttonsCell, for: workflowState!)
            return buttonsCell
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? F4SInviteDetailLinkCell {
            cell.buttonAction = nil
        }
    }
    
    func configureButtonCell(_ buttonsCell: F4SInviteButtonsTableViewCell, for state: F4SPlacementState) {
        buttonsCell.applyStyle()
        switch state {
        case .accepted:
            buttonsCell.introductoryText.text = NSLocalizedString("Please choose an option in order to proceed", comment: "")
            buttonsCell.primaryButton.isHidden = false
            buttonsCell.secondaryButton.isHidden = false
            buttonsCell.shareButton.isHidden = false
            buttonsCell.shareText.isHidden = false
            buttonsCell.primaryButton.setTitle("Proceed to accept", for: .normal)
            buttonsCell.secondaryButton.setTitle("Decline", for: .normal)
            buttonsCell.primaryAction = { [weak self] in
                self?.proceedWithApplication()
            }
            buttonsCell.secondaryAction = { [weak self] in
                guard let strongSelf = self else { return }
                let uuid = strongSelf.accept.placement.placementUuid!
                strongSelf.declineApplication(uuid: uuid)
            }
            buttonsCell.shareOffer = { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.accept.presentShare(from: strongSelf, sourceView: buttonsCell.shareButton)
            }
            
        case .confirmed:
            buttonsCell.introductoryText.text = NSLocalizedString("Please be aware that this cannot be undone", comment: "")
            buttonsCell.primaryButton.isHidden = true
            buttonsCell.secondaryButton.isHidden = false
            buttonsCell.secondaryButton.setTitle("Cancel placement", for: .normal)
            buttonsCell.shareButton.isHidden = false
            buttonsCell.shareText.isHidden = false
            buttonsCell.primaryAction = nil
            buttonsCell.secondaryAction = { [weak self] in
                guard let strongSelf = self else { return }
                let uuid = strongSelf.accept.placement.placementUuid!
                strongSelf.cancelApplication(uuid: uuid)
            }
            buttonsCell.shareOffer = { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.accept.presentShare(from: strongSelf, sourceView: buttonsCell.shareButton)
            }
            
        default:
            buttonsCell.introductoryText.isHidden = true
            buttonsCell.primaryButton.isHidden = true
            buttonsCell.secondaryButton.isHidden = true
            buttonsCell.shareButton.isHidden = true
            buttonsCell.shareText.isHidden = true
            buttonsCell.primaryAction = nil
            buttonsCell.secondaryAction = nil
        }
    }
}

// MARK:- UITableViewDelegate
extension AcceptOfferViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "header") as! F4SInviteSectionHeaderTableViewCell
        if section < placementInviteModel.numberOfSections() {
            let header = placementInviteModel.headerForSection(section)
            cell.title.text = header.title
        } else {
            cell.title.text = ""
        }
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let headerHeight = headerHeight else { return }
        let constant = max(initialHeaderHeight - scrollView.contentOffset.y/2.0,40)
        headerHeight.constant = constant
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 67
    }
}

// MARK:- Handle button interactions
extension AcceptOfferViewController {
    
    func proceedWithApplication() {
        sharedUserMessageHandler.showLoadingOverlay(self.view)
        let age = accept.user.age() ?? 0
        companyDocumentsModel.getDocuments(age: age) { (result) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                sharedUserMessageHandler.hideLoadingOverlay()
                switch result {
                case .error(let error):
                    if error.retry == true {
                        sharedUserMessageHandler.display(error, parentCtrl: strongSelf, cancelHandler: nil, retryHandler: {
                            strongSelf.proceedWithApplication()
                        })
                    } else {
                        sharedUserMessageHandler.display(error, parentCtrl: strongSelf, cancelHandler: nil, retryHandler: nil)
                    }
                case .success(_):
                    sharedUserMessageHandler.hideLoadingOverlay()
                    if strongSelf.companyDocumentsModel.requestableDocuments.count > 0 {
                        strongSelf.performSegue(withIdentifier: "showRequestCompanyDocuments", sender: strongSelf)
                    } else {
                        strongSelf.performSegue(withIdentifier: "showVoucherEntry", sender: strongSelf)
                    }
                }
            }
        }
    }
    
    func declineApplication(uuid: F4SUUID) {
        sharedUserMessageHandler.showLoadingOverlay(self.view)
        offerProcessor.declinePlacement(uuid) { (result) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                sharedUserMessageHandler.hideLoadingOverlay()
                switch result {
                case .error(let error):
                    sharedUserMessageHandler.display(error, parentCtrl: strongSelf, cancelHandler: nil, retryHandler: {
                        strongSelf.declineApplication(uuid: uuid)
                    })
                case .success(_):
                    let title = "Offer declined"
                    let message = "You have declined this offer of work experience"
                    let alert = UIAlertController(
                        title: title,
                        message: message, preferredStyle: .alert)
                    let okAction = UIAlertAction(
                        title: "OK",
                        style: .default,
                        handler: { (_) in
                            strongSelf.coordinator?.didDecline()
                    })
                    alert.addAction(okAction)
                    strongSelf.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func cancelApplication(uuid: F4SUUID) {
        sharedUserMessageHandler.showLoadingOverlay(self.view)
        offerProcessor.cancelPlacement(uuid) { (result) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                sharedUserMessageHandler.hideLoadingOverlay()
                switch result {
                case .error(let error):
                    sharedUserMessageHandler.display(error, parentCtrl: strongSelf, cancelHandler: nil, retryHandler: {
                        strongSelf.cancelApplication(uuid: uuid)
                    })
                case .success(_):
                    let title = "Placement cancelled"
                    let message = "You have cancelled your placement"
                    let alert = UIAlertController(
                        title: title,
                        message: message, preferredStyle: .alert)
                    let okAction = UIAlertAction(
                        title: "OK",
                        style: .default,
                        handler: { (_) in
                            strongSelf.coordinator?.didCancel()
                    })
                    alert.addAction(okAction)
                    strongSelf.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}





