//
//  EnterVoucherViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 20/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class EnterVoucherViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var voucherText: UITextField!
    @IBOutlet weak var statusIcon: UIImageView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var getOneButton: UIButton!
    
    @IBOutlet weak var validationLabel: UILabel!
    
    var accept: AcceptOfferContext!

    var voucher: F4SVoucher!

    var confirmView: F4SConfirmUseVoucherView? = nil
    
    @IBAction func acceptButtonTapped(_ sender: Any) {
        addConfirmView()
    }
    
    func addConfirmView() {
        if self.confirmView == nil {
            let confirmView = F4SConfirmUseVoucherView()
            confirmView.code = voucher.code
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
        MessageHandler.sharedInstance.showLoadingOverlay(self.view)
        accept.voucher = voucher
        placementService = F4SPlacementService()
        placementService?.confirmPlacement(placement: accept.placement, voucherCode: accept.voucher!.code, completion: {
            (confirmResult) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                MessageHandler.sharedInstance.hideLoadingOverlay()
                switch  confirmResult {
                case .error(let error):
                    if error.retry {
                        MessageHandler.sharedInstance.display(error, parentCtrl: strongSelf, cancelHandler: nil, retryHandler: {
                            strongSelf.processAcceptDecision(result: result)
                        })
                    } else {
                        MessageHandler.sharedInstance.display(error, parentCtrl: strongSelf)
                    }
                case .success(let success):
                    if success == true {
                        self?.performSegue(withIdentifier: "showHooray", sender: strongSelf)
                    } else {
                        log.error("confirm placement failed with an unexpected error in the response body")
                    }
                }
            }
        })
    }

    @IBOutlet weak var pageHeaderView: F4SCompanyHeaderViewWithLogo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        voucher = F4SVoucher(placement: accept.placement.placementUuid!)
        voucherText.isEnabled = false
        voucherText.text = ""
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: .UIKeyboardWillChangeFrame, object: nil)
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
//        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
//        let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! UInt
        let curFrame = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let targetFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY = targetFrame.origin.y - curFrame.origin.y
        accododateKeyboardOffset(viewHeightDelta: deltaY)
    }
    
    func accododateKeyboardOffset(viewHeightDelta: CGFloat) {
        let currentOffset = scrollView.contentOffset
        let yOffset: CGFloat
        if viewHeightDelta < 0 {
            yOffset =  0.0 - viewHeightDelta/2.0
        } else {
            yOffset = currentOffset.y - viewHeightDelta/2.0
        }
        let point = CGPoint(x: currentOffset.x, y: yOffset )
        scrollView.setContentOffset(point, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isTranslucent = true
        self.tabBarController?.tabBar.isHidden = true
        print("placement \(accept.placement)")
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
        guard string.rangeOfCharacter(from: F4SVoucher.disallowedSymbols) == nil else { return false }
        guard let stringRange = Range(range, in: currentText) else { return false }
        let proposedText = currentText.replacingCharacters(in: stringRange, with: string)
        if proposedText.count > 6 { return false }
        if proposedText == voucher.code { return true }
        configureForCode(proposedText)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        voucher.cancelServerValidation()
        configureForCode("")
        return true
    }
    
    func configureForCode(_ code: String) {
        voucher.code = code
        voucherText.isEnabled = true
        acceptButton.isEnabled = false
        if voucher.passesClientsideRules() {
            voucher.state = .validOnClient
            voucher.validateOnServer() { [weak self] error in
                guard let strongSelf = self else { return }
                if let error = error {
                    switch error {
                    case .networkError:
                        strongSelf.showNetworkErrorAndRetry(error: error)
                    case .alreadyUsed:
                        strongSelf.voucher.setStateFromServerCodeValidationError(error: error)
                    case .invalid:
                        strongSelf.voucher.setStateFromServerCodeValidationError(error: error)
                    case .other:
                        strongSelf.voucher.setStateFromServerCodeValidationError(error: error)
                    }
                    
                    strongSelf.updateAppearanceForVoucherState()
                    return
                }
                strongSelf.voucher.state = F4SVoucher.State.available
                strongSelf.voucherText.isEnabled = false
                strongSelf.acceptButton.isEnabled = true
                strongSelf.accept.voucher = strongSelf.voucher
                strongSelf.updateAppearanceForVoucherState()
                return
            }
        } else {
            voucher.state = .invalidOnClient
            voucher.cancelServerValidation()
            updateAppearanceForVoucherState()
        }
    }
    
    func updateAppearanceForVoucherState() {
        let duration = 0.4
        statusIcon.image = voucher.statusSymbol
        UIView.animate(withDuration: duration) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.voucherText.layer.borderWidth = 2
            strongSelf.voucherText.layer.borderColor = strongSelf.voucher.borderColorForState
            switch strongSelf.voucher.state {
            case .invalidOnClient:
                if strongSelf.voucher.code.count == 0  {
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
    
    func showNetworkErrorAndRetry(error: F4SVoucher.CodeValidationError) {
        view.endEditing(true)
        let alert = UIAlertController(title: "No network", message: "Please make sure you have an internet connection", preferredStyle: .alert)
        let action = UIAlertAction(title: "Retry", style: .default, handler: { [weak self] action in
            guard let strongSelf = self else { return }
            strongSelf.configureForCode(strongSelf.voucher.code)
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
        Skinner().apply(buttonSkin: skin?.primaryButtonSkin, to: acceptButton)
    }
}

public class F4SVoucher {
    
    var service: F4SVoucherVerificationServiceProtocol?
    
    enum CodeValidationError: Error {
        case networkError
        case alreadyUsed
        case invalid
        case other
    }
    enum State {
        case invalidOnClient
        case validOnClient
        case unknownOnServer
        case alreadyUsed
        case available
    }
    
    var placement: F4SUUID = ""
    var code: String = ""
    var state: State = .invalidOnClient
    
    public init(placement: F4SUUID) {
        self.placement = placement
        self.code = ""
        state = .invalidOnClient
    }
    
    func passesClientsideRules() -> Bool {
        return code.count == 6
    }
    
    func cancelServerValidation() {
        service?.cancel()
    }
    
    func validateOnServer(completion: @escaping (CodeValidationError?)->()) {
        cancelServerValidation()
        if placement.isEmpty || code.isEmpty { return }
        let service = F4SVoucherVerificationService(placementUuid: placement, voucherCode:  code)
        service.verify(completion: { (result) in
            DispatchQueue.main.async {
                switch result {
                case .error(let error):
                    if error.retry {
                        completion(CodeValidationError.networkError)
                    } else {
                        completion(CodeValidationError.other)
                    }
                    
                case .success(let verificationResult):
                    if verificationResult.errors == nil{
                        completion(nil)
                    } else {
                        completion(CodeValidationError.alreadyUsed)
                    }
                }
            }
        })
        self.service = service
    }
}

extension String {
    func stripCompanySuffix() -> String {
        let companyEndings = [" limited", " ltd", "ltd.", " plc"]
        var stripped = self
        companyEndings.forEach { (ending) in
            if hasSuffix(ending) || hasSuffix(ending.uppercased()){
                stripped = String(dropLast(ending.count))
            }
        }
        return stripped
    }
}

extension F4SVoucher {
    static var allowedSymbols: CharacterSet {
        return CharacterSet.alphanumerics
    }
    static var disallowedSymbols: CharacterSet {
        return CharacterSet.alphanumerics.inverted
    }
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
    
    func setStateFromServerCodeValidationError(error: CodeValidationError) {
        switch error {
        case .networkError:
            // Show retry alert
            state = F4SVoucher.State.unknownOnServer
            break
        case .alreadyUsed:
            state = F4SVoucher.State.alreadyUsed
            break
        case .invalid:
            state = F4SVoucher.State.unknownOnServer
            break
        case .other:
            state = F4SVoucher.State.unknownOnServer
            break
        }
        return
    }
}


