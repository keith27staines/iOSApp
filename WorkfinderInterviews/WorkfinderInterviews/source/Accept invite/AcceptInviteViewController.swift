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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        styleNavigationController()
        load()
    }

    
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
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
