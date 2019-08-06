//
//  CompanyViewController.swift
//  F4SPrototypes
//
//  Created by Keith Staines on 21/12/2018.
//  Copyright © 2018 Keith Staines. All rights reserved.
//

import UIKit
import WorkfinderUI

class CompanySubViewController: UIViewController {
    let viewModel: CompanyViewModel
    let pageIndex: CompanyViewModel.PageIndex
    
    init(viewModel: CompanyViewModel, pageIndex: CompanyViewModel.PageIndex) {
        self.viewModel = viewModel
        self.pageIndex = pageIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refresh() {
        fatalError("This method must be overridden")
    }
}
