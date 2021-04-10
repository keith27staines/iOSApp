//
//  YourDetailsViewController.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 10/04/2021.
//

import UIKit
import WorkfinderCommon

class YourDetailsViewController:  WFViewController {
    
    var yourDetailsPresenter: YourDetailsPresenter { presenter as! YourDetailsPresenter }
    
    override func registerTableCells() {
        // tableView.register(AMPHeaderCell.self, forCellReuseIdentifier: AMPHeaderCell.reuseIdentifier)

    }
    
    override func configureNavigationBar() {
        super.configureNavigationBar()
        navigationItem.title = "Your Details"
    }
    
    init(coordinator: AccountCoordinator, presenter: YourDetailsPresenter) {
        super.init(coordinator: coordinator, presenter: presenter)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
