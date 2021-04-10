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
        // tableView.register(AMPHeaderCell.self, forCellReuseIdentifier: AMPHeaderCell.reuseIdentifier)

    }
    
    override func configureNavigationBar() {
        super.configureNavigationBar()
        navigationItem.title = "Account Preferences"
    }
    
}
