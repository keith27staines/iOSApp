//
//  ChangePasswordViewController.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 15/04/2021.
//

import UIKit
import WorkfinderUI

class ChangePasswordViewController: WFViewController {
    
    lazy var currentPassword: UnderlinedNextResponderTextFieldStack = {
        let view = UnderlinedNextResponderTextFieldStack(fieldName: "current password", goodUnderlineColor: WorkfinderColors.primaryColor, badUnderlineColor: WorkfinderColors.badValueActive, state: .empty, nextResponderField: nil)
        view.textfield.autocapitalizationType = .none
        view.textfield.autocorrectionType = .no
        view.textfield.textContentType = .password
        view.state = .empty
        return view
    }()
    
    lazy var newPassword: UnderlinedNextResponderTextFieldStack = {
        let view = UnderlinedNextResponderTextFieldStack(fieldName: "new password", goodUnderlineColor: WorkfinderColors.primaryColor, badUnderlineColor: WorkfinderColors.badValueActive, state: .empty, nextResponderField: nil)
        view.textfield.autocapitalizationType = .none
        view.textfield.autocorrectionType = .no
        view.textfield.textContentType = .newPassword
        view.textfield.isEnabled = false
        view.state = .empty
        return view
    }()
    
    lazy var confirmPassword: UnderlinedNextResponderTextFieldStack = {
        let view = UnderlinedNextResponderTextFieldStack(fieldName: "confirm password", goodUnderlineColor: WorkfinderColors.primaryColor, badUnderlineColor: WorkfinderColors.badValueActive, state: .empty, nextResponderField: nil)
        view.textfield.autocapitalizationType = .none
        view.textfield.autocorrectionType = .no
        view.textfield.textContentType = .newPassword
        view.textfield.isEnabled = false
        view.state = .empty
        return view
    }()
    
    func makeSpacerView(height: CGFloat) -> UIView {
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: height).isActive = true
        return spacer
    }
    
    lazy var currentPasswordStack:UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
                currentPassword,
                makeSpacerView(height: 20)
            ]
        )
        stack.spacing = 8
        stack.axis = .vertical
        return stack
    }()
    
    lazy var newPasswordStack:UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
                newPassword,
                confirmPassword
            ]
        )
        stack.spacing = 8
        stack.axis = .vertical
        return stack
    }()
    
    lazy var verticalStack:UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
                currentPasswordStack,
                newPasswordStack,
                makeSpacerView(height: 12),
                button
            ]
        )
        stack.spacing = 8
        stack.axis = .vertical
        return stack
    }()
    
    lazy var button: UIButton = {
        let button = WorkfinderPrimaryButton()
        button.setTitle("Change password", for: .normal)
        button.addTarget(self, action: #selector(submit), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    @objc func submit() {
        guard let newPassword = newPassword.textfield.text else { return }
        (presenter as? ChangePasswordPresenter)?.changePassword(newPassword: newPassword) { optionalError in
            messageHandler.displayOptionalErrorIfNotNil(optionalError, cancelHandler: {
                
            }, retryHandler: { [ weak self] in
                self?.submit()
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        
    }
    
    override func configureViews() {
        view.backgroundColor = UIColor.white
        let guide = view.safeAreaLayoutGuide
        view.addSubview(verticalStack)
        verticalStack.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: nil, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20))
    }
    
    override func configureNavigationBar() {
        super.configureNavigationBar()
        navigationItem.title = "Change password"
    }
    
    var alowSubmit: Bool {
        return false
    }
    
}


