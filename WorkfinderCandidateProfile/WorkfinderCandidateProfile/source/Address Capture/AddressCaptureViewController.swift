//
//  AddressCaptureViewController.swift
//  WorkfinderCoordinators
//
//  Created by Keith Staines on 18/03/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI
import WorkfinderServices

class AddressCaptureViewController: UIViewController {
    
    let service = ValidatePostcodeService()
    let hideBackButton: Bool
    var onComplete: (() -> Void)?
    let updateCandidateService: UpdateCandidateServiceProtocol
    let candidateRepository: UserRepositoryProtocol
    
    lazy var messageHandler = UserMessageHandler(presenter: self)
    
    
    lazy var heading: UILabel = {
        let label = UILabel()
        label.text = "Where do you live?"
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "We are asking this because this employer has expressed a preference that candidates are resident in a certain area."
        label.font = UIFont.systemFont(ofSize: 15, weight: .light)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    var postcodeString: String?
    
    lazy var postcode: UnderlinedNextResponderTextFieldStack = {
        let view = UnderlinedNextResponderTextFieldStack(fieldName: "postcode", goodUnderlineColor: WorkfinderColors.goodValueNormal, badUnderlineColor: WorkfinderColors.badValueNormal, state: .empty, nextResponderField: nil)
        view.textfield.autocapitalizationType = .allCharacters
        view.textfield.textContentType = .postalCode
        view.textChanged = { text in
            guard let text = text else {
                view.state = .empty
                return
            }
            guard text.isUKPostcode() else {
                self.primaryButton.isEnabled = false
                view.state = .bad
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                self.service.validatePostcode(text) { (result) in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(_):
                            self.primaryButton.isEnabled = true
                            self.postcodeString = text
                            view.state = .good
                        case .failure(let error):
                            self.primaryButton.isEnabled = false
                            view.state = .bad
                        }
                    }
                }
            }
        }
        return view
    }()
    
    lazy var primaryButton: WorkfinderPrimaryButton = {
        let button = WorkfinderPrimaryButton()
        button.setTitle("Next", for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(onPrimaryButtonTap), for: .touchUpInside)
        return button
    }()
    
    @objc func onPrimaryButtonTap() {
        var candidate = candidateRepository.loadCandidate()
        guard
            let postcodeString = postcodeString,
            let candidateUuid = candidate.uuid else { return }
        messageHandler.showLightLoadingOverlay()
        updateCandidateService.updatePostcode(candidateUuid: candidateUuid, postcode: postcodeString) { [weak self] result in
            guard let self = self else { return }
            self.messageHandler.hideLoadingOverlay()
            switch result {
            case .success(_):
                candidate.postcode = postcodeString
                self.candidateRepository.saveCandidate(candidate)
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
            postcode,
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
        title = "Postcode"
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
        updateCandidateService: UpdateCandidateServiceProtocol,
        candidateRepository: UserRepositoryProtocol,
        onComplete: @escaping () -> Void
    ) {
        self.hideBackButton = hideBackButton
        self.onComplete = onComplete
        self.updateCandidateService = updateCandidateService
        self.candidateRepository = candidateRepository
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
