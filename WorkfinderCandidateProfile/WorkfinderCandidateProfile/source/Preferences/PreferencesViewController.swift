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
    
    var preferencesPresenter: YourDetailsPresenter { presenter as! YourDetailsPresenter }
    
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
