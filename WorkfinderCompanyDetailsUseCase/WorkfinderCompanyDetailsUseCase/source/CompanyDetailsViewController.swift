//
//  CompanyMainViewController.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 21/01/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI

protocol CompanyDetailsViewProtocol : CompanyHostsSectionViewProtocol {
    var presenter: CompanyDetailsPresenterProtocol! { get set }
    func refresh()
    func showLoadingIndicator()
    func hideLoadingIndicator(_ presenter: WorkplacePresenter)
    func showNetworkError(_ error: Error, retry: (() -> Void)?)
}

class CompanyDetailsViewController: UIViewController {
    var presenter: CompanyDetailsPresenterProtocol!
    weak var coordinator: CompanyDetailsCoordinatorProtocol!
    weak var log: F4SAnalyticsAndDebugging?
    lazy var messageHandler = UserMessageHandler(presenter: self)
    let appSource: AppSource
    
    init(presenter: CompanyDetailsPresenterProtocol, appSource: AppSource) {
        self.presenter = presenter
        self.appSource = appSource
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    private var loadingInProgressCount: Int = 0
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    func refresh() {
        companyMainPageView.refresh()
    }
    
    lazy var companyMainPageView: CompanyMainView = {
        let view = CompanyMainView(presenter: self.presenter.mainViewPresenter)
        view.log = log
        return view
    }()
    
    override func viewDidLoad() {
        configureNavigationBar()
        presenter.onViewDidLoad(self)
        view.addSubview(companyMainPageView)
        companyMainPageView.fillSuperview()
        log?.track(.company_hosts_page_view(appSource))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isMovingFromParent {
            log?.track(.company_hosts_page_dismiss(appSource))
            presenter.onTapBack()
        }
    }
    
    func configureNavigationBar() {
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = "Company details"
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        styleNavigationController()
    }
    
    func incrementLoadingInProgressCount() {
        if loadingInProgressCount == 0 {
            messageHandler.showLightLoadingOverlay(view)
        }
        loadingInProgressCount += 1
    }
    
    func decrementLoadingInProgressCount() {
        if loadingInProgressCount == 1 {
            messageHandler.hideLoadingOverlay()
            refresh()
        }
        if loadingInProgressCount > 0 {
            loadingInProgressCount -= 1
        }
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension CompanyDetailsViewController: CompanyDetailsViewProtocol {
    
    func showLoadingIndicator() {
        incrementLoadingInProgressCount()
    }
    
    func hideLoadingIndicator(_ presenter: WorkplacePresenter) {
        decrementLoadingInProgressCount()
        refresh()
    }
    
    func showNetworkError(_ error: Error, retry: (() -> Void)?) {
        messageHandler.displayOptionalErrorIfNotNil(
            error,
            cancelHandler: { self.decrementLoadingInProgressCount() },
            retryHandler: { retry?() } )
    }
}
