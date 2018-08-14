//
//  AcceptOfferViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 18/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class AcceptOfferViewController: UIViewController {
    @IBOutlet weak var offsetHeight: NSLayoutConstraint!
    
    @IBOutlet weak var headerHeight: NSLayoutConstraint!

    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let splashColor = UIColor(red: 66/255, green: 192/255, blue: 236/255, alpha: 1.0)
    
    let initialHeaderHeight: CGFloat = 100.0
    
    @IBOutlet weak var pageHeaderView: F4SCompanyHeaderViewWithLogo!
    
    var placementInviteModel: F4SPlacementInviteModel!
    var accept: AcceptOfferContext!
    var companyDocumentsModel: F4SCompanyDocumentsModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placementInviteModel = F4SPlacementInviteModel(context: accept)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        applyStyle()
        companyNameLabel.text = accept.company.name.stripCompanySuffix()
        pageHeaderView.icon = accept.companyLogo
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isTranslucent = true
        self.tabBarController?.tabBar.isHidden = true
        styleNavigationController(titleColor: UIColor.white, backgroundColor: splashColor, tintColor: UIColor.white, useLightStatusBar: true)
        captureShareImage()
    }
    
    func captureShareImage() {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        accept.offerImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let enterVoucherViewController = segue.destination as? EnterVoucherViewController {
            enterVoucherViewController.accept = accept
            return
        }
        if let requestDocumentsViewController = segue.destination as? RequestBLProvideDocuments {
            requestDocumentsViewController.accept = accept
            requestDocumentsViewController.companyDocumentsModel = self.companyDocumentsModel
            return
        }
    }
}

extension AcceptOfferViewController {
    func applyStyle() {
        pageHeaderView.backgroundColor = UIColor.white
        navigationItem.title = ""
        pageHeaderView.fillColor = splashColor
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
            let buttonsCell = tableView.dequeueReusableCell(withIdentifier: "buttons") as! F4SInviteButtonsTableViewCell
            let workflowState = accept.placement.workflowState
            configureButtonCell(buttonsCell, for: workflowState!)
            return buttonsCell
        }
    }
    
    func configureButtonCell(_ buttonsCell: F4SInviteButtonsTableViewCell, for state: F4SPlacementStatus) {
        F4SButtonStyler.apply(style: .primary, button: buttonsCell.primaryButton)
        F4SButtonStyler.apply(style: .secondary, button: buttonsCell.secondaryButton)
        
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
                strongSelf.declineApplication(uuid: strongSelf.accept.placement.placementUuid!)
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
                strongSelf.cancelApplication(uuid: strongSelf.accept.placement.placementUuid!)
            }
            buttonsCell.shareOffer = nil
        default:
            buttonsCell.introductoryText.isHidden = true
            buttonsCell.primaryButton.isHidden = true
            buttonsCell.secondaryButton.isHidden = true
            buttonsCell.shareButton.isHidden = true
            buttonsCell.shareText.isHidden = true
            buttonsCell.primaryAction = nil
            buttonsCell.secondaryAction = nil
            buttonsCell.shareText = nil
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
        MessageHandler.sharedInstance.showLoadingOverlay(self.view)
        self.companyDocumentsModel = F4SCompanyDocumentsModel(companyUuid: accept.company.uuid)
        let companyDocumentsModel = self.companyDocumentsModel!
        companyDocumentsModel.getDocuments { (result) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                MessageHandler.sharedInstance.hideLoadingOverlay()
                switch result {
                case .error(let error):
                    if error.retry == true {
                        MessageHandler.sharedInstance.display(error, parentCtrl: strongSelf, cancelHandler: nil, retryHandler: {
                            strongSelf.proceedWithApplication()
                        })
                    } else {
                        MessageHandler.sharedInstance.display(error, parentCtrl: strongSelf, cancelHandler: nil, retryHandler: nil)
                    }
                case .success(_):
                    MessageHandler.sharedInstance.hideLoadingOverlay()
                    if companyDocumentsModel.requestableDocuments.count > 0 {
                        strongSelf.performSegue(withIdentifier: "showRequestCompanyDocuments", sender: strongSelf)
                    } else {
                        strongSelf.performSegue(withIdentifier: "showVoucherEntry", sender: strongSelf)
                    }
                }
            }
        }
    }
    
    func declineApplication(uuid: F4SUUID) {
        MessageHandler.sharedInstance.showLoadingOverlay(self.view)
        let service = F4SPlacementService()
        service.declinePlacement(uuid) { (result) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                MessageHandler.sharedInstance.hideLoadingOverlay()
                switch result {
                case .error(let error):
                    MessageHandler.sharedInstance.display(error, parentCtrl: strongSelf, cancelHandler: nil, retryHandler: {
                        strongSelf.declineApplication(uuid: uuid)
                    })
                case .success(_):
                    log.debug("invite was declined by YP")
                    strongSelf.navigationController?.popViewController(animated: true)
                    break
                }
            }
        }
    }
    
    func cancelApplication(uuid: F4SUUID) {
        MessageHandler.sharedInstance.showLoadingOverlay(self.view)
        let service = F4SPlacementService()
        service.cancelPlacement(uuid) { (result) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                MessageHandler.sharedInstance.hideLoadingOverlay()
                switch result {
                case .error(let error):
                    MessageHandler.sharedInstance.display(error, parentCtrl: strongSelf, cancelHandler: nil, retryHandler: {
                        strongSelf.cancelApplication(uuid: uuid)
                    })
                case .success(_):
                    log.debug("invite was cancelled by YP")
                    strongSelf.navigationController?.popViewController(animated: true)
                    break
                }
            }
        }
    }
}




