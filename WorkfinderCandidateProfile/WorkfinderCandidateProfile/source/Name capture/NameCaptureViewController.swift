//
//  NameCaptureViewController.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith on 21/07/2021.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI
import WorkfinderServices

class NameCaptureViewController: UIViewController {
    
    let service: UpdateUserService
    let hideBackButton: Bool
    var onComplete: (() -> Void)?
    lazy var messageHandler = UserMessageHandler(presenter: self)
    
    let userRepository: UserRepositoryProtocol
    
    lazy var heading: UILabel = {
        let label = UILabel()
        label.text = "Please tell us your name"
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "We are asking this because we want to address you correctly when we communicate with you"
        label.font = UIFont.systemFont(ofSize: 15, weight: .light)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    var firstName: String? {
        didSet {
            guard let firstName = firstName else {
                firstNameStack.state = .empty
                return
            }
            firstNameStack.state = firstName.isValidNameComponent ? .good : .bad
            updatePrimaryButtonEnabledState()
        }
    }
    
    var lastName: String? {
        didSet {
            guard let lastName = lastName else {
                lastNameStack.state = .empty
                return
            }
            lastNameStack.state = lastName.isValidNameComponent ? .good : .bad
            updatePrimaryButtonEnabledState()
        }
    }
    
    lazy var firstNameStack: UnderlinedNextResponderTextFieldStack = {
        let view = UnderlinedNextResponderTextFieldStack(fieldName: "first name", goodUnderlineColor: WorkfinderColors.goodValueNormal, badUnderlineColor: WorkfinderColors.badValueNormal, state: .empty, nextResponderField: lastNameStack.textfield)
        view.textfield.autocapitalizationType = .words
        view.textfield.textContentType = .givenName
        view.state = .empty
        view.textChanged = { text in
            self.firstName = text
        }
        return view
    }()

    lazy var lastNameStack: UnderlinedNextResponderTextFieldStack = {
        let view = UnderlinedNextResponderTextFieldStack(fieldName: "last name", goodUnderlineColor: WorkfinderColors.goodValueNormal, badUnderlineColor: WorkfinderColors.badValueNormal, state: .empty, nextResponderField: nil)
        view.textfield.autocapitalizationType = .words
        view.textfield.textContentType = .familyName
        view.state = .empty
        view.textChanged = { text in
            self.lastName = text
        }
        return view
    }()
    
    private func updatePrimaryButtonEnabledState() {
        primaryButton.isEnabled = firstName?.isValidNameComponent == true && lastName?.isValidNameComponent == true
    }
    
    lazy var primaryButton: WorkfinderPrimaryButton = {
        let button = WorkfinderPrimaryButton()
        button.setTitle("Next", for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(onPrimaryButtonTap), for: .touchUpInside)
        return button
    }()
    
    @objc func onPrimaryButtonTap() {
        let userRepository = UserRepository()
        guard
            let firstName = firstName,
            let lastName = lastName
        else { return }
        
        messageHandler.showLightLoadingOverlay()
        service.updateUserName(firstName: firstName, lastName: lastName) { [weak self] result in
            guard let self = self else { return }
            self.messageHandler.hideLoadingOverlay()
            switch result {
            case .success(_):
                var user = userRepository.loadUser()
                user.firstname = firstName
                user.lastname = lastName
                userRepository.saveUser(user)
                self.onComplete?()
            case .failure(let error):
                self.messageHandler.displayOptionalErrorIfNotNil(error, retryHandler: nil)
            }
        }
    }
    
    lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            heading,
            label
        ])
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()
    
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            textStack,
            firstNameStack,
            lastNameStack,
            primaryButton
        ])
        stack.axis = .vertical
        stack.spacing = 30
        return stack
    }()
    
    override func viewDidLoad() {
        configureNavigationBar()
        configureViews()
    }
    
    func configureNavigationBar() {
        title = "Name"
        navigationItem.hidesBackButton = hideBackButton
    }
    
    func configureViews() {
        view.backgroundColor = UIColor.white
        let guide = view.safeAreaLayoutGuide
        view.addSubview(stack)
        stack.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: nil, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 40, left: 20, bottom: 0, right: 20))
    }
    
    init(
        hideBackButton: Bool,
        updateUserService: UpdateUserService,
        userRepository: UserRepositoryProtocol,
        onComplete: @escaping () -> Void
    ) {
        self.hideBackButton = hideBackButton
        self.onComplete = onComplete
        self.service = updateUserService
        self.userRepository = userRepository
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

