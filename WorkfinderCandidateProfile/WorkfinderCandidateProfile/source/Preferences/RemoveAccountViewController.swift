//
//  RemoveAccountViewController.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith on 27/05/2021.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI

class RemoveAccountViewController: UIViewController {
    
    lazy var messageHandler = UserMessageHandler(presenter: self)
    
    var email = ""
    weak var coordinator: AccountCoordinator?
    
    var headingString: String {
        let user = UserRepository().loadUser()
        var name = (user.firstname ?? user.fullname) ?? ""
        if name.count > 0 { name = name + ","}
        return "\(name) we are sorry to see you go"
        
    }
    let descriptionString = "You will lose your profile, job recommendations, and more from Workfinder.\n\nAre you sure you want to close your account?"
    let confirmString = "Enter your email to confirm closure"
    
    lazy var headingLabel: UILabel = {
        let label = UILabel()
        label.text = headingString
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = descriptionString
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = WorkfinderColors.gray3
        label.numberOfLines = 0
        return label
    }()
    
    lazy var confirmLabel: UILabel = {
        let label = UILabel()
        label.text = confirmString
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = WorkfinderColors.gray3
        label.numberOfLines = 0
        return label
    }()
    
    lazy var emailField: UITextField = {
        let email = UITextField()
        email.font = UIFont.systemFont(ofSize: 19, weight: .regular)
        email.placeholder = "your email"
        email.borderStyle = .roundedRect
        email.autocapitalizationType = .none
        email.autocorrectionType = .no
        email.textContentType = .emailAddress
        email.keyboardType = .emailAddress
        email.addTarget(self, action: #selector(emailTextChanged), for: .editingChanged)
        return email
    }()
    
    lazy var confirmStack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(confirmLabel)
        stack.addArrangedSubview(emailField)
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()
    
    lazy var cancelButton: UIButton = {
        let button = WorkfinderSecondaryButton()
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return button
    }()

    lazy var removeButton: UIButton = {
        let button = WorkfinderPrimaryButton()
        button.setTitle("Remove", for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(removeAccount), for: .touchUpInside)
        return button
    }()

    lazy var buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(cancelButton)
        stack.addArrangedSubview(removeButton)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()
    
    lazy var textStack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(headingLabel)
        stack.addArrangedSubview(descriptionLabel)
        stack.addArrangedSubview(confirmStack)
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()

    lazy var mainStack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(textStack)
        stack.addArrangedSubview(buttonStack)
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()
    
    @objc func emailTextChanged(sender: UITextField) {
        email = sender.text ?? ""
        removeButton.isEnabled = email.isEmail()
    }
    
    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func removeAccount() {
        guard email.isEmail() else { return }
        coordinator?.permanentlyRemoveAccountFromServer(email: email, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.dismiss(animated: true) {
                    self.onRemoveAccountSubmitted?()
                }
            case .failure(let error):
                self.messageHandler.displayOptionalErrorIfNotNil(error) {
                    return
                } retryHandler: {
                    self.removeAccount()
                }
            }
        })
    }
    
    init(coordinator: AccountCoordinator, onRemoveAccountSubmitted: @escaping () -> Void) {
        self.coordinator = coordinator
        self.onRemoveAccountSubmitted = onRemoveAccountSubmitted
        super.init(nibName: nil, bundle: nil)
    }
    
    var onRemoveAccountSubmitted: (() -> Void)?
    
    override func viewDidLoad() {
        configureViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureNavBar()
    }
    
    func configureViews() {
        view.backgroundColor = UIColor.white
        view.addSubview(mainStack)
        let guide = view.safeAreaLayoutGuide
        mainStack.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: nil, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
    }
    
    func configureNavBar() {
        styleNavigationController()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
