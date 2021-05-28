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
    let descriptionString = "You will lose your profile, job recommendations, and more from Workfinder. Are you sure you want to close your account?"
    let confirmString = "Enter your email to confirm closure"
    
    lazy var headingLabel: UILabel = {
        let label = UILabel()
        label.text = headingString
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = descriptionString
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var confirmLabel: UILabel = {
        let label = UILabel()
        label.text = confirmString
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        return label
    }()
    
    lazy var emailField: UITextField = {
        let email = UITextField()
        email.placeholder = "your email "
        email.borderStyle = .roundedRect
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
        return button
    }()

    lazy var removeButton: UIButton = {
        let button = WorkfinderPrimaryButton()
        button.setTitle("Remove", for: .normal)
        button.isEnabled = false
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
        stack.spacing = 8
        return stack
    }()

    lazy var mainStack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(textStack)
        stack.addArrangedSubview(buttonStack)
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    @objc func cancel() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func removeAccount() {
        guard email.isEmail() else { return }
        coordinator?.permanentlyRemoveAccountFromServer(email: email, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.removeAccountCompleted()
            case .failure(let error):
                self.messageHandler.displayOptionalErrorIfNotNil(error) {
                    return
                } retryHandler: {
                    self.removeAccount()
                }
            }
        })
    }
    
    func removeAccountCompleted() {
        let alert = UIAlertController(
            title: "Account deleted",
            message: "We are arranging for the deletion of your details as you requested, and you are now logged out. Thank you for using Workfinder.",
            preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close", style: .default) { [weak self] (action) in
            guard let self = self else { return }
            self.dismiss(animated: true) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        }
        alert.addAction(closeAction)
        present(alert, animated: true, completion: nil)
    }
    
    init(coordinator: AccountCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
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
