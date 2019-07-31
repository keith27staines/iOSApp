//
//  EnterVoucherViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 20/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit
import MessageUI
import WorkfinderCommon
import WorkfinderServices
import WorkfinderAppLogic

class EnterVoucherViewController: UIViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var voucherText: UITextField!
    @IBOutlet weak var statusIcon: UIImageView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var getOneButton: UIButton!
    
    @IBOutlet weak var validationLabel: UILabel!
    
    var accept: AcceptOfferContext!

    var voucherLogic: F4SVoucherLogic!

    var confirmView: F4SConfirmUseVoucherView? = nil
    
    @IBAction func acceptButtonTapped(_ sender: Any) {
        addConfirmView()
    }
    
    @IBAction func getVoucherTapped(_ sender: Any) {
        let email: String = "support@workfinder.com"
        guard MFMailComposeViewController.canSendMail() else {
            let alert = UIAlertController(title: "Get voucher", message: "Please send an email requesting vouchers to", preferredStyle: .actionSheet)
            let doneAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(doneAction)
            return
        }
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        // Configure the fields of the interface.
        composeVC.setToRecipients([email])
        composeVC.setSubject("Voucher")
        composeVC.setMessageBody("", isHTML: false)
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func addConfirmView() {
        if self.confirmView == nil {
            let confirmView = F4SConfirmUseVoucherView()
            confirmView.code = voucherLogic.code
            confirmView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(confirmView)
            self.confirmView = confirmView
            confirmView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            confirmView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
            confirmView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            confirmView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            confirmView.result = processAcceptDecision
        }
    }
    
    func removeConfirmView() {
        confirmView?.removeFromSuperview()
        confirmView = nil
    }
    
    var placementService: F4SPlacementService?
    
    func processAcceptDecision(result: Bool) {
        confirmView?.removeFromSuperview()
        confirmView = nil
        
        guard result else {
            removeConfirmView()
            return
        }
        sharedUserMessageHandler.showLoadingOverlay(self.view)
        accept.voucherLogic = voucherLogic
        placementService = F4SPlacementService()
        placementService?.confirmPlacement(placement: accept.placement, voucherCode: accept.voucherLogic!.code, completion: {
            (confirmResult) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                sharedUserMessageHandler.hideLoadingOverlay()
                switch  confirmResult {
                case .error(let error):
                    if error.retry {
                        sharedUserMessageHandler.display(error, parentCtrl: strongSelf, cancelHandler: nil, retryHandler: {
                            strongSelf.processAcceptDecision(result: result)
                        })
                    } else {
                        sharedUserMessageHandler.display(error, parentCtrl: strongSelf)
                    }
                case .success(let success):
                    if success == true {
                        self?.performSegue(withIdentifier: "showHooray", sender: strongSelf)
                    } else {
                        globalLog.error("confirm placement failed with an unexpected error in the response body")
                    }
                }
            }
        })
    }

    @IBOutlet weak var pageHeaderView: F4SCompanyHeaderViewWithLogo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        voucherLogic = F4SVoucherLogic(placement: accept.placement.placementUuid!)
        voucherText.isEnabled = false
        voucherText.text = ""
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        scrollView.isScrollEnabled = false
        companyNameLabel.text = accept.company.name.stripCompanySuffix()
        pageHeaderView.icon = accept.companyLogo
        validationLabel.isHidden = true
        voucherText.delegate = self
        applyStyle()
        voucherText.layer.cornerRadius = 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let text = ""
        voucherText.text = text
        configureForCode(text)
    }
    
    @objc func keyboardWillChange(notification: NSNotification) {
        let curFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let targetFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY = -(targetFrame.origin.y - curFrame.origin.y)
        accommodateKeyboardOffset(viewHeightDelta: deltaY)
    }
    
    func accommodateKeyboardOffset(viewHeightDelta: CGFloat) {
        let currentOffset = scrollView.contentOffset
        let voucherGapToKeyboard = voucherDistanceFromBottom - viewHeightDelta
        if voucherGapToKeyboard < 8 {
            let point = CGPoint(x: currentOffset.x, y: 8 - voucherGapToKeyboard )
            scrollView.setContentOffset(point, animated: true)
        } else {
            let point = CGPoint(x: currentOffset.x, y: 0 )
            scrollView.setContentOffset(point, animated: true)
        }
    }
    
    var voucherDistanceFromBottom: CGFloat {
        let maxY = voucherText.bounds.maxY
        var pt = CGPoint(x: 0, y: maxY)
        pt = voucherText.convert(pt, to: nil)
        guard let windowHeight = view.window?.frame.size.height else { return 0 }
        let d = windowHeight - pt.y
        return d
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isTranslucent = true
        self.tabBarController?.tabBar.isHidden = true
        styleNavigationController()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showHooray" {
            guard let vc = segue.destination as? F4SHoorayViewController else { return }
            vc.accept = accept
        }
    }
    
}

extension EnterVoucherViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard string.rangeOfCharacter(from: F4SVoucherLogic.disallowedSymbols) == nil else { return false }
        guard let stringRange = Range(range, in: currentText) else { return false }
        let proposedText = currentText.replacingCharacters(in: stringRange, with: string)
        if proposedText.count > 6 { return false }
        if proposedText == voucherLogic.code { return true }
        configureForCode(proposedText)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        voucherLogic.cancelServerValidation()
        configureForCode("")
        return true
    }
    
    func configureForCode(_ code: String) {
        voucherLogic.code = code
        voucherText.isEnabled = true
        acceptButton.isEnabled = false
        if voucherLogic.passesClientsideRules() {
            voucherLogic.state = .validOnClient
            voucherLogic.validateOnServer() { [weak self] error in
                guard let strongSelf = self else { return }
                if let error = error {
                    switch error {
                    case .networkError:
                        strongSelf.showNetworkErrorAndRetry(error: error)
                    case .alreadyUsed:
                        strongSelf.voucherLogic.setStateFromServerCodeValidationError(error: error)
                    case .invalid:
                        strongSelf.voucherLogic.setStateFromServerCodeValidationError(error: error)
                    case .other:
                        strongSelf.voucherLogic.setStateFromServerCodeValidationError(error: error)
                    }
                    
                    strongSelf.updateAppearanceForVoucherState()
                    return
                }
                strongSelf.voucherLogic.state = F4SVoucherLogic.State.available
                strongSelf.voucherText.isEnabled = false
                strongSelf.acceptButton.isEnabled = true
                strongSelf.accept.voucherLogic = strongSelf.voucherLogic
                strongSelf.updateAppearanceForVoucherState()
                return
            }
        } else {
            voucherLogic.state = .invalidOnClient
            voucherLogic.cancelServerValidation()
            updateAppearanceForVoucherState()
        }
    }
    
    func updateAppearanceForVoucherState() {
        let duration = 0.4
        statusIcon.image = voucherLogic.statusSymbol
        UIView.animate(withDuration: duration) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.voucherText.layer.borderWidth = 2
            strongSelf.voucherText.layer.borderColor = strongSelf.voucherLogic.borderColorForState
            switch strongSelf.voucherLogic.state {
            case .invalidOnClient:
                if strongSelf.voucherLogic.code.count == 0  {
                    strongSelf.statusIcon.transform = CGAffineTransform(rotationAngle: 0.0)
                } else {
                    strongSelf.statusIcon.transform = CGAffineTransform(rotationAngle: CGFloat.pi/4.0)
                }
                strongSelf.validationLabel.isHidden = true
            case .validOnClient:
                strongSelf.statusIcon.transform = CGAffineTransform(rotationAngle: CGFloat.pi/4.0)
                strongSelf.validationLabel.isHidden = true
            case .unknownOnServer:
                strongSelf.statusIcon.transform = CGAffineTransform(rotationAngle: 0.0)
                strongSelf.validationLabel.isHidden = false
            case .alreadyUsed:
                strongSelf.statusIcon.transform = CGAffineTransform(rotationAngle: 0.0)
                strongSelf.validationLabel.isHidden = false
            case .available:
                strongSelf.statusIcon.transform = CGAffineTransform(rotationAngle: 0.0)
                strongSelf.validationLabel.isHidden = true
            }
        }
    }
    
    func showNetworkErrorAndRetry(error: F4SVoucherLogic.CodeValidationError) {
        view.endEditing(true)
        let alert = UIAlertController(title: "No network", message: "Please make sure you have an internet connection", preferredStyle: .alert)
        let action = UIAlertAction(title: "Retry", style: .default, handler: { [weak self] action in
            guard let strongSelf = self else { return }
            strongSelf.configureForCode(strongSelf.voucherLogic.code)
        })
        alert.addAction(action)
        present(alert, animated: true) {
            
        }
    }
}

extension EnterVoucherViewController {
    func applyStyle() {
        pageHeaderView.backgroundColor = UIColor.white
        navigationItem.title = ""
        pageHeaderView.fillColor = splashColor
        pageHeaderView.leftDrop = 1.0
        pageHeaderView.rightDrop = 0.1
        Skinner().apply(buttonSkin: skin?.primaryButtonSkin, to: acceptButton)
    }
}

extension F4SVoucherLogic {

    var statusSymbol: UIImage {
        switch state {
        case .invalidOnClient:
            return UIImage(named: "ui-pluscircle-icon")!
        case .validOnClient:
            return UIImage(named: "ui-pluscircle-icon")!
        case .unknownOnServer:
            return UIImage(named: "ui-errorcircle-icon")!
        case .alreadyUsed:
            return UIImage(named: "ui-errorcircle-icon")!
        case .available:
            return UIImage(named: "ui-tickcircle-icon")!
        }
    }
    
    var borderColorForState: CGColor {
        switch state {
        case .invalidOnClient:
            return UIColor.orange.cgColor
        case .validOnClient:
            return UIColor.orange.cgColor
        case .unknownOnServer:
            return UIColor.red.cgColor
        case .alreadyUsed:
            return UIColor.red.cgColor
        case .available:
            return UIColor.green.cgColor
        }
    }
}


