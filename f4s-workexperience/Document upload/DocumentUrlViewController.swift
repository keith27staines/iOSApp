//
//  DocumentUrlViewController.swift
//  UrlUploadDemo
//
//  Created by Keith Dev on 15/02/2018.
//  Copyright © 2018 Keith Dev. All rights reserved.
//

import UIKit

class DocumentUrlViewController: UIViewController {
    var urlTableViewController: URLTableViewController?
    lazy var documentUrlModel: F4SDocumentUploadModel = {
        return F4SDocumentUploadModel(delegate: self, placementUuid: self.applicationContext.placement!.placementUuid!)
    }()
    
    var applicationContext: F4SApplicationContext!
    
    @IBOutlet weak var topImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet var plusButtonCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var plusButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var plusButtonLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var plusButton: UIImageView!
    
    @IBOutlet weak var plusButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var addAnother: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    let consentPreviouslyGivenKey = "consentPreviouslyGivenKey"
    var isSetupForDisplayingUrls: Bool = false
    
    lazy var userService: F4SUserService = {
        return F4SUserService()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        plusButton.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(addLinkButtonTapped))
        plusButton.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupForCentralPlusButton()
        plusButton.isUserInteractionEnabled = false
        applyStyle()
    }
    
    func setupForFetchedData() {
        guard documentUrlModel.numberOfRows(for: 0) > 0 else {
            setupForCentralPlusButton()
            updateEnabledStateOfAddButton()
            return
        }
        transitionToDisplayUrls()
        urlTableViewController?.tableView.reloadData()
        updateEnabledStateOfAddButton()
    }
    
    func applyStyle() {
        Skinner().apply(buttonSkin: skin?.primaryButtonSkin, to: continueButton)
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        continueButton.isEnabled = false
        continueAsyncWorker()
    }
    
    func continueAsyncWorker() {
        MessageHandler.sharedInstance.showLoadingOverlay(view)
        documentUrlModel.putDocuments { (success) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.continueButton.isEnabled = true
                if success {
                    strongSelf.submitApplication(applicationContext: strongSelf.applicationContext)
                } else {
                    MessageHandler.sharedInstance.hideLoadingOverlay()
                    strongSelf.displayTryAgain(completion: strongSelf.continueAsyncWorker)
                }
            }
        }
    }
    
    func submitApplication(applicationContext: F4SApplicationContext) {
        var user = applicationContext.user!
        userService.updateUser(user: user) { [weak self] (result) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                MessageHandler.sharedInstance.hideLoadingOverlay()
                switch result {
                case .success(let userModel):
                    guard let uuid = userModel.uuid else {
                        MessageHandler.sharedInstance.displayWithTitle("Oops something went wrong", "Workfinder cannot complete this operation", parentCtrl: strongSelf)
                        return
                    }
                    user.updateUuidAndPersistToLocalStorage(uuid: uuid)
                    F4SNetworkSessionManager.shared.rebuildSessions() // Ensure session manager is aware of the possible change of user uuid
                    var updatedContext = applicationContext
                    updatedContext.user = user
                    var updatedPlacement = applicationContext.placement!
                    updatedPlacement.status = F4SPlacementStatus.applied
                    updatedContext.placement = updatedPlacement
                    strongSelf.applicationContext = updatedContext
                    PlacementDBOperations.sharedInstance.savePlacement(placement: updatedPlacement)
                    UserDefaults.standard.set(true, forKey: strongSelf.consentPreviouslyGivenKey)
                    strongSelf.afterSubmitApplication(applicationContext: updatedContext)
                case .error(let error):
                    MessageHandler.sharedInstance.display(error, parentCtrl: strongSelf, cancelHandler: nil) {
                        MessageHandler.sharedInstance.showLoadingOverlay(strongSelf.view)
                        strongSelf.submitApplication(applicationContext: applicationContext)
                    }
                }
            }
        }
    }
    
    func afterSubmitApplication(applicationContext: F4SApplicationContext) {
        CustomNavigationHelper.sharedInstance.presentSuccessExtraInfoPopover(
            parentCtrl: self)
    }
    
    @objc func addLinkButtonTapped() {
        if !isSetupForDisplayingUrls {
            transitionToDisplayUrls()
        }
        urlTableViewController?.createNewLink()
    }
    
    @IBAction func showCVGuide(_ sender: Any) {
        let url = URL(string:"https://interactive.barclayslifeskills.com/staticmodules/downloads/cv-tips.pdf")!
        UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
    func updateEnabledStateOfAddButton() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            let numberShown = self.documentUrlModel.numberOfRows(for: 0)
            if numberShown > 0 {
                if self.documentUrlModel.doAllDescriptorsContainValidLinks() {
                    if self.documentUrlModel.canAddPlaceholder() {
                        self.transitionSmallPlusButton(toRed: true, text: "Add another")
                    } else {
                        let maxUrls = self.documentUrlModel.maximumDocumentCount
                        self.transitionSmallPlusButton(toRed: false, text: "You have added the maximum of \(maxUrls) links")
                    }
                } else {
                    self.transitionSmallPlusButton(toRed: false, text: "Tap below to paste your link")
                }
            } else {
                self.transitionToBigPlusButton()
            }
        }
    }
    
    func transitionSmallPlusButton(toRed: Bool, text:String) {
        self.addAnother.fadeTransition(0.4)
        self.addAnother.text = text
        guard let plusButton = self.plusButton else { return }
        let image = toRed ? #imageLiteral(resourceName: "redPlusSmall") : #imageLiteral(resourceName: "greyPlus")
        plusButton.isUserInteractionEnabled = toRed
        UIView.transition(with: plusButton,
                          duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: { plusButton.image = image },
                          completion: nil)
    }
    
    func transitionToBigPlusButton() {
        guard isSetupForDisplayingUrls else {
            plusButton.isUserInteractionEnabled = true
            return
        }
        setupForCentralPlusButton()
        let containerView = self.containerView!
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.view.layoutIfNeeded()
            containerView.alpha = 0
        }) { (success) in
            containerView.isHidden = true
        }
        plusButton.isUserInteractionEnabled = true
    }
    
    @objc func transitionToDisplayUrls() {
        guard !isSetupForDisplayingUrls else { return }
        let view = self.view!
        let containerView = self.containerView!
        containerView.isHidden = false
        setupForDisplayingUrls()
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
            view.layoutIfNeeded()
            containerView.alpha = 1.0
        }) { (success) in
            
        }
    }
    
    func setupForCentralPlusButton() {
        isSetupForDisplayingUrls = false
        plusButtonCenterConstraint.isActive = true
        plusButtonHeightConstraint.constant = 70
        plusButtonTopConstraint.constant = 40
        plusButton.image = #imageLiteral(resourceName: "redPlus") // standard size version
        plusButton.transform = CGAffineTransform.identity
        containerView.alpha = 0
        containerView.isHidden = true
        addAnother.alpha = 0.0
    }

    func setupForDisplayingUrls() {
        isSetupForDisplayingUrls = true
        plusButtonCenterConstraint.isActive = false
        plusButtonHeightConstraint.constant = 35
        plusButtonTopConstraint.constant = 10
        plusButton.image = documentUrlModel.numberOfRows(for: 0) < 3 ? #imageLiteral(resourceName: "redPlusSmall") : #imageLiteral(resourceName: "greyPlus")
        plusButton.transform = CGAffineTransform.identity
        containerView.frame = plusButton.frame
        addAnother.alpha = 1.0
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedUrlDisplay" {
            urlTableViewController = (segue.destination as! URLTableViewController)
            urlTableViewController?.documentUploadModel = documentUrlModel
        }
    }
}

extension DocumentUrlViewController : F4SDocumentUploadModelDelegate {
    func documentUploadModelFailedToFetchDocuments(_ model: F4SDocumentUploadModel, error: Error) {
        displayTryAgain { [weak self] in
            self?.documentUrlModel.fetchDocumentsForPlacement()
        }
    }
    
    func displayTryAgain(completion: @escaping ()->()) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: "No internet connection", message: "Please make sure you have an internet connection and try again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: { (action) in
                completion()
            }))
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    func documentUploadModelFetchedDocuments(_ model: F4SDocumentUploadModel) {
        DispatchQueue.main.async { [weak self] in
            self?.setupForFetchedData()
        }
    }
    func documentUploadModel(_ model: F4SDocumentUploadModel, deleted: F4SDocument) {
        updateEnabledStateOfAddButton()
    }
    func documentUploadModel(_ model: F4SDocumentUploadModel, updated: F4SDocument) {
        updateEnabledStateOfAddButton()
    }
    func documentUploadModel(_ model: F4SDocumentUploadModel, created: F4SDocument) {
        updateEnabledStateOfAddButton()
    }
}
extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: convertFromCATransitionType(CATransitionType.fade))
    }
}














// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCATransitionType(_ input: CATransitionType) -> String {
	return input.rawValue
}
