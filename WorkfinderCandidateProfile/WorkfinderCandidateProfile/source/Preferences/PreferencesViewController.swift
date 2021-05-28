//
//  PreferencesViewController.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 10/04/2021.
//

import Foundation
import UIKit
import WorkfinderCommon

class PreferencesViewController:  WFViewController {
    
    var preferencesPresenter: PreferencesPresenter { presenter as! PreferencesPresenter }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preferencesPresenter.viewController = self
    }
    
    func removeAccountRequested() {
        guard let coordinator = coordinator else { return }
        let vc = RemoveAccountViewController(coordinator: coordinator, onRemoveAccountSubmitted: removeAccountCompleted)
        navigationController?.present(vc, animated: true, completion: nil)
        return
    }
    
    func removeAccountCompleted() {
        let alert = UIAlertController(
            title: "Account deleted",
            message: "We are arranging for the deletion of your details as you requested, and you are now logged out. Thank you for using Workfinder.",
            preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close", style: .default) { [weak self] (action) in
            self?.navigationController?.popViewController(animated: true)
        }
        alert.addAction(closeAction)
        present(alert, animated: true, completion: nil)
    }
    
    override func registerTableCells() {
        tableView.register(EnableNotificationsCell.self, forCellReuseIdentifier: EnableNotificationsCell.reuseIdentifier)
        tableView.register(NotificationControlsCell.self, forCellReuseIdentifier: NotificationControlsCell.reuseIdentifier)
        tableView.register(MarketingEmailCell.self, forCellReuseIdentifier: MarketingEmailCell.reuseIdentifier)
        tableView.register(RemoveAccountCell.self, forCellReuseIdentifier: RemoveAccountCell.reuseIdentifier)
    }
    
    override func configureNavigationBar() {
        super.configureNavigationBar()
        navigationItem.title = "Account Preferences"
    }
    
    init(coordinator: AccountCoordinator, presenter: PreferencesPresenter) {
        super.init(coordinator: coordinator, presenter: presenter)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
