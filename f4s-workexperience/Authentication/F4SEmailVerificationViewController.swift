//
//  F4SEmailVerificationViewController.swift
//
//  Created by Keith Dev on 04/12/2017.
//  Copyright © 2017 F4S. All rights reserved.
//

import UIKit

class F4SEmailVerificationViewController: UIViewController {
    
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var introductionLabel: UILabel!
    @IBOutlet weak var secondaryActionButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var primaryActionButton: UIButton!
    
    public var emailToVerify: String? = nil

    /// A callback to inform the presenter that the email was verified
    var emailWasVerified: (() -> Void)? = nil

    /// The finite state machine that serves as the model for this view
    lazy var model: F4SEmailVerificationModel = {
        let m = F4SEmailVerificationModel()
        m.didChangeState = handleStateChange(oldState:newState:)
        return m
    }()
    
    /// Maintains a count of the number of asynchronous activities in progress
    private var activityCount: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.text = emailToVerify ?? ""
        emailTextField.delegate = self
        emailTextField.enablesReturnKeyAutomatically = false
        activitySpinner.hidesWhenStopped = true
        activitySpinner.isHidden = true
        activityCount = 0
    }
    
    @IBAction func bypassButtonTapped(_ sender: UIButton) {
        emailWasVerified?()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if emailToVerify != nil {
            startVerifying()
        }
        configure(for: model.emailVerificationState)
        applyStyle()
    }
    
    func applyStyle() {
        F4SButtonStyler.apply(style: .primary, button: primaryActionButton)
        F4SButtonStyler.apply(style: .secondary, button: secondaryActionButton)
        F4SBackgroundViewStyler.apply(style: .standardPageBackground, backgroundView: self.view)
    }
    
    func handleStateChange(oldState: F4SEmailVerificationState, newState: F4SEmailVerificationState) {
        configure(for: newState)
    }
}

// MARK: Action handlers
extension F4SEmailVerificationViewController {
    @IBAction func primaryActionButtonPressed(_ sender: Any) {
        switch model.emailVerificationState {
        case .start, .emailSent(_):
            startVerifying()
        case  .verified, .previouslyVerified:
            emailWasVerified?()
        case .error(_):
            emailToVerify = emailTextField.text
            model.restart()
        default:
            assertionFailure("Shouldn't happen. Was the primary button left enabled when it shouldn't have been?")
            break
        }
    }
    
    public func startVerifying() {
        // Primary button is used to tell us to submit email address to receive link
        guard let email = emailTextField.text else {
            return
        }
        emailToVerify = email.trimmingCharacters(in: .whitespacesAndNewlines)
        emailTextField.text = emailToVerify
        emailToVerify = nil
        emailTextField.resignFirstResponder()
        emailTextField.isEnabled = false
        startActivity()
        model.submitEmailForVerification(email) { [weak self] in
            self?.finishActivity()
        }
    }

    @IBAction func secondaryActionButtonPressed(sender: UIButton) {
        switch model.emailVerificationState {
        case .previouslyVerified:
            model.restart()
        case .emailSent(_):
            model.restart()
        default:
            assertionFailure("Shouldn't happen. Was the secondary button left enabled when it shouldn't have been?")
            break
        }
    }
    
    func backToPrevious() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK:- Start and stop activity
extension F4SEmailVerificationViewController {
    func startActivity() {
        activityCount += 1
        feedbackLabel.text = ""
        activitySpinner.isHidden = false
        activitySpinner.startAnimating()
    }
    
    func finishActivity() {
        assert(activityCount > 0, "Not all activity starts have been paired with finishes")
        activityCount -= 1
        if activityCount == 0 {
            activitySpinner.stopAnimating()
        }
    }
}

// MARK:- UITextFieldDelegate
extension F4SEmailVerificationViewController : UITextFieldDelegate {
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            configure(primaryActionButton, visible: false, enabled: false)
            return true
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            primaryActionButtonPressed(self)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == emailTextField {
            let currentText = textField.text ?? ""
            let currentNSString = currentText as NSString
            let changedText = currentNSString.replacingCharacters(in: range, with: string)
            model.restart()
            configurePrimaryActionButtonForStartStateWithEmail(email: changedText)
        }
        return true
    }
}

// MARK:- UI state machine
extension F4SEmailVerificationViewController {
    
    func configure(for state: F4SEmailVerificationState) {
        _ = view
        introductionLabel.text = model.lastNonErrorState.introductionString
        feedbackLabel.text = state.feedbackString
        configure(emailTextField, visible: state.isEMailFieldVisible, enabled: state.isEmailFieldEnabled)
        configure(primaryActionButton, visible: state.isPrimaryButtonVisible, enabled: state.isPrimaryButtonEnabled)
        configure(secondaryActionButton, visible: state.isSecondaryButtonVisible, enabled: state.isSecondaryButtonEnabled)
        primaryActionButton.setTitle(state.titleForPrimary, for: .normal)
        secondaryActionButton.setTitle(state.titleForSecondary, for: .normal)
        
        switch state {
        case .start:
            emailTextField.text = emailToVerify ?? ""
            configurePrimaryActionButtonForStartStateWithEmail(email: emailTextField.text)
        case .emailSent:
            emailTextField.text = model.emailSentForVerification
            emailTextField.resignFirstResponder()
        case .linkReceived:
            emailTextField.text = model.emailSentForVerification
            emailTextField.resignFirstResponder()
        case .verified:
            emailTextField.text = model.verifiedEmail
            emailTextField.resignFirstResponder()
        case .previouslyVerified:
            emailTextField.text = model.verifiedEmail
            self.emailTextField.resignFirstResponder()
        case .error(_):
            self.emailTextField.resignFirstResponder()
        }
    }
    
    func configure(_ control: UIControl, visible: Bool, enabled: Bool) {
        control.alpha = visible ? 1.0 : 0.0
        control.isEnabled = visible ? enabled : false
    }
    
    func configurePrimaryActionButtonForStartStateWithEmail(email: String?) {
        if model.basicEmailFormatValidator(email: email) {
            configure(primaryActionButton, visible: true, enabled: true)
        } else {
            configure(primaryActionButton, visible: false, enabled: false)
        }
        if !emailTextField.isFirstResponder {
            emailTextField.becomeFirstResponder()
        }
    }
}

