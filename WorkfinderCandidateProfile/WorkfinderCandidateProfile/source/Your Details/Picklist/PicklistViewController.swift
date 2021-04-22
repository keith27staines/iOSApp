//
//  PicklistViewController.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 14/04/2021.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI

class PicklistViewController: WFViewController {
    override func configureNavigationBar() {
        super.configureNavigationBar()
        navigationItem.title = (presenter as? PicklistPresenter)?.picklist.type.title
    }
}

