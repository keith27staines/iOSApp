//
//  LinkedinConnectionView.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith on 02/07/2021.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI

class LinkedinConnectionViewController: UIViewController {
    lazy var messageHandler: UserMessageHandler = UserMessageHandler(presenter: self)
    let presenter: LinkedinConnectionPresenter
    
    override func viewDidLoad() {
        presenter.onViewDidLoad(self)
        reloadFromPresenter()
        configureViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        configureNavBar()
    }
    
    func reloadFromPresenter() {
        presenter.loadLinkedinConnection { [weak self] optionalError in
            guard let self = self else { return }
            self.messageHandler.displayOptionalErrorIfNotNil(
                optionalError,
                cancelHandler: {},
                retryHandler: self.reloadFromPresenter)
            self.table.reloadData()
        }
    }
    
    lazy var connectLabel: UILabel = {
        let label = UILabel()
        label.text = "Connect your LinkedIn account so that Workfinder can provide more information about you to employers"
        label.numberOfLines = 0
        return label
    }()
    
    lazy var connectButton: UIButton = {
        let button = WorkfinderPrimaryButton()
        button.setTitle("Connect LinkedIn", for: .normal)
        return button
    }()
    
    lazy var connectStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.addArrangedSubview(connectLabel)
        stack.addArrangedSubview(connectButton)
        return stack
    }()
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.addArrangedSubview(connectStack)
        stack.addArrangedSubview(table)
        return stack
    }()
    
    lazy var table: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        return table
    }()
    
    func configureViews() {
        view.backgroundColor = UIColor.white
        let guide = view.safeAreaLayoutGuide
        view.addSubview(mainStack)
        mainStack.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor)
    }
    
    func configureNavBar() {
        styleNavigationController()
        navigationItem.title = "LinkedIn data"
    }
    
    init(presenter: LinkedinConnectionPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
