//
//  ProjectViewController.swift
//  WorkfinderInterviews
//
//  Created by Keith on 20/07/2021.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI

class ProjectViewController: UIViewController {
    
    lazy var messageHandler = UserMessageHandler(presenter: self)
    weak var coordinator: AcceptInviteCoordinatorProtocol?
    let presenter: ProjectPresenter
    
    override func viewDidLoad() {
        configureViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureNavigationBar()
        loadPresenter()
    }
    
    func loadPresenter() {
        messageHandler.showLoadingOverlay()
        presenter.load { [weak self] optionalError in
            guard let self = self else { return }
            self.messageHandler.hideLoadingOverlay()
            messageHandler.displayOptionalErrorIfNotNil(optionalError) {
                self.navigationController?.popViewController(animated: true)
            } retryHandler: {
                self.loadPresenter()
            }
            self.refreshFromPresenter()
        }
    }
    
    func refreshFromPresenter() {
        
    }
    
    init(coordinator: AcceptInviteCoordinatorProtocol, presenter: ProjectPresenter) {
        self.coordinator = coordinator
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    private func configureViews() {
        view.backgroundColor = UIColor.white
    }
    
    private func configureNavigationBar() {
        styleNavigationController()
        navigationItem.title = "Project details"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
