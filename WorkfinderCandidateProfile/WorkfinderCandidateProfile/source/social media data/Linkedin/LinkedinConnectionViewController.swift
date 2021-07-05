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
            
            if let isDataAvailable = self.presenter.isLinkedinDataAvailable {
                self.connectStack.isHidden = isDataAvailable
                self.table.isHidden = !self.connectStack.isHidden
            }
        }
    }
    
    lazy var connectLabel: UILabel = {
        let label = UILabel()
        label.text = "If you connect your LinkedIn account, Workfinder will be able to provide more information to employers"
        label.textAlignment = .center
        label.textColor = WorkfinderColors.gray3
        label.numberOfLines = 0
        return label
    }()
    
    lazy var connectButton: UIButton = {
        let button = WorkfinderPrimaryButton()
        button.setTitle("Connect LinkedIn", for: .normal)
        return button
    }()
    
    lazy var connectVStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.addArrangedSubview(connectLabel)
        stack.addArrangedSubview(connectButton)
        return stack
    }()

    lazy var connectStack: UIStackView = {
        let space1 = UIView()
        let space2 = UIView()
        space1.widthAnchor.constraint(equalToConstant: 20).isActive = true
        space2.widthAnchor.constraint(equalToConstant: 20).isActive = true
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 0
        stack.addArrangedSubview(space1)
        stack.addArrangedSubview(connectVStack)
        stack.addArrangedSubview(space2)
        stack.isHidden = true
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
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = UITableView.automaticDimension
        return table
    }()
    
    func configureViews() {
        view.backgroundColor = UIColor.white
        let guide = view.safeAreaLayoutGuide
        view.addSubview(mainStack)
        mainStack.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor,padding: UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0))
    }
    
    func configureNavBar() {
        styleNavigationController()
        navigationItem.title = "LinkedIn connection"
    }
    
    init(presenter: LinkedinConnectionPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
