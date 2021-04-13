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
        let alert = UIAlertController(title: "Are you sure you want us to remove your account?", message: "If you are sure, we will delete your details from our database.\nThis cannot be undone.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { [weak self] (action) in
            self?.coordinator?.permanentlyRemoveAccount() { [weak self] optionalError in
                guard let self = self else { return }
                self.removeAccountCompleted()
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(removeAction)
        present(alert, animated: true, completion: nil)
    }
    
    func removeAccountCompleted() {
        let alert = UIAlertController(title: "Account deleted", message: "We have deleted your details as you requested, and you are now logged out. Thank you for using Workfinder.", preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close", style: .default) { (action) in
            
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
