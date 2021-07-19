//
//  AcceptInvite.swift
//  WorkfinderInterviews
//
//  Created by Keith on 14/07/2021.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI

class AcceptInviteViewController: UIViewController {
    
    lazy var messageHandler = UserMessageHandler(presenter: self)
    weak var coordinator: AcceptInviteCoordinatorProtocol?
    let presenter: AcceptInvitePresenter
    
    init(coordinator: AcceptInviteCoordinatorProtocol, presenter: AcceptInvitePresenter) {
        self.coordinator = coordinator
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        configureViews()
        title = "Interview"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        styleNavigationController()
        load()
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.text = "You have been invited for an interview with Workfinder!"
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var introLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = WorkfinderColors.gray3
        label.text = "You can select an alternative date if the suggested one isn't good for you"
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = WorkfinderColors.gray3
        label.numberOfLines = 0
        return label
    }()
    
    lazy var projectDetailsButton: UIButton = {
        let button = UIButton()
        button.setTitle("project details", for: .normal)
        button.setTitleColor(WorkfinderColors.primaryColor, for: .normal)
        button.addTarget(self, action: #selector(didTapSeeProjectDetails), for: .touchUpInside)
        return button
    }()
    
    @objc func didTapSeeProjectDetails() {
        coordinator?.showProjectDetails()
    }
    
    lazy var chooseDateButton: UIButton = {
        let button = UIButton()
        button.setTitle("Choose different date", for: .normal)
        button.setTitleColor(WorkfinderColors.primaryColor, for: .normal)
        button.addTarget(self, action: #selector(didTapChooseDifferentDate), for: .touchUpInside)
        return button
    }()
    
    @objc func didTapChooseDifferentDate() {
        messageHandler.showLoadingOverlay()
        presenter.didTapChooseDifferentDate { [weak self] optionalError in
            guard let self = self else { return }
            self.messageHandler.hideLoadingOverlay()
            self.messageHandler.displayOptionalErrorIfNotNil(optionalError) {
                
            } retryHandler: {
                self.didTapChooseDifferentDate()
            }
        }
    }

    lazy var acceptButton: UIButton = {
        let button = WorkfinderPrimaryButton()
        button.setTitle("Accept", for: .normal)
        button.addTarget(self, action: #selector(didTapAcceptButton), for: .touchUpInside)
        return button
    }()
    
    @objc func didTapAcceptButton() {
        messageHandler.showLoadingOverlay()
        presenter.onDidTapAccept { [weak self] optionalError in
            guard let self = self else { return }
            self.messageHandler.hideLoadingOverlay()
            self.messageHandler.displayOptionalErrorIfNotNil(optionalError) {
                
            } retryHandler: {
                self.didTapAcceptButton()
            }
        }
    }
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(projectDetailsButton)
        stack.addArrangedSubview(dateLabel)
        stack.addArrangedSubview(acceptButton)
        stack.addArrangedSubview(introLabel)
        stack.addArrangedSubview(chooseDateButton)
        return stack
    }()
    
    private func load() {
        messageHandler.showLoadingOverlay()
        presenter.load { [weak self] optionalError in
            guard let self = self else { return }
            self.messageHandler.hideLoadingOverlay()
            self.messageHandler.displayOptionalErrorIfNotNil(optionalError) {
                self.coordinator?.acceptViewControllerDidCancel(self)
            } retryHandler: {
                self.load()
            }
            self.presenterDidUpdate()
        }
    }
    
    func presenterDidUpdate() {
        
    }
    
    
    func configureNaviationBar() {
        styleNavigationController()
    }
    
    func configureViews() {
        view.backgroundColor = UIColor.white
        let guide = view.safeAreaLayoutGuide
        view.addSubview(mainStack)
        mainStack.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: nil, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
