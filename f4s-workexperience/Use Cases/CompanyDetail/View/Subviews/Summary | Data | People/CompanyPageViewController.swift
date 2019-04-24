//
//  CompanyPageViewController.swift
//  F4SPrototypes
//
//  Created by Keith Staines on 21/12/2018.
//  Copyright © 2018 Keith Staines. All rights reserved.
//

import UIKit

protocol CompanyPageViewControllerDelegate : class, CompanyPeopleViewControllerDelegate {}

class CompanyPageViewController: UIPageViewController {
    
    let viewModel : CompanyViewModel
    var companyDelegate: CompanyPageViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewControllers([viewModel.currentViewController], direction: .forward, animated: false, completion: nil)
        moveToPage(index: CompanyViewModel.PageIndex.summary)
    }
    
    func moveToPage(index: CompanyViewModel.PageIndex?) {
        guard let index = index else { return }
        if let direction = viewModel.transitionDirectionForPage(index) {
            viewModel.currentPageIndex = index
            viewModel.currentViewController.refresh()
            setViewControllers([viewModel.currentViewController], direction: direction, animated: true, completion: nil)
        }
    }
    
    func refresh() {
        viewModel.currentViewController.refresh()
    }
    
    init(viewModel: CompanyViewModel) {
        self.viewModel = viewModel
        super.init(
            transitionStyle: UIPageViewController.TransitionStyle.scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
