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

protocol CompanyWorkplaceViewProtocol : CompanyHostsSectionViewProtocol {
    var presenter: CompanyWorkplacePresenterProtocol! { get set }
    func refresh()
    func showLoadingIndicator()
    func hideLoadingIndicator(_ presenter: CompanyWorkplacePresenter)
    func showNetworkError(_ error: Error, retry: (() -> Void)?)
}

class CompanyWorkplaceViewController: UIViewController {
    var presenter: CompanyWorkplacePresenterProtocol!
    weak var coordinator: CompanyCoordinatorProtocol!
    let screenName = ScreenName.company
    var originScreen = ScreenName.notSpecified
    weak var log: F4SAnalyticsAndDebugging?
    var appSettings: AppSettingProvider
    lazy var messageHandler = UserMessageHandler(presenter: self)
    
    init(appSettings: AppSettingProvider, presenter: CompanyWorkplacePresenterProtocol) {
        self.appSettings = appSettings
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    private var loadingInProgressCount: Int = 0
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    func refresh() {
        companyMainPageView.refresh()
    }
    
    lazy var companyMainPageView: CompanyMainView = {
        let view = CompanyMainView(
            appSettings: appSettings,
            presenter: self.presenter.mainViewPresenter)
        view.log = log
        return view
    }()
    
    override func viewDidLoad() {
        presenter.onViewDidLoad(self)
        view.addSubview(companyMainPageView)
        companyMainPageView.fillSuperview()
        log?.track(event: .companyDetailsScreenDidLoad, properties: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureNavigationBar()
        refresh()
    }
    
    lazy var leftButton: UIBarButtonItem = {
        let button = UIButton(type: .system)
        let leftChevron = UIImage(named: "Back")?.withRenderingMode(.alwaysTemplate).scaledImage(with: CGSize(width: 20, height: 20))
        button.setImage(leftChevron, for: .normal)
        button.setTitle("Back", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        button.sizeToFit()
        button.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    func configureNavigationBar() {
        navigationController?.isNavigationBarHidden = false
        styleNavigationController()
        navigationItem.leftBarButtonItem = leftButton
    }
    
    @objc func didTapBack() {
        presenter.onTapBack()
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

extension CompanyWorkplaceViewController: CompanyWorkplaceViewProtocol {
    
    func showLoadingIndicator() {
        incrementLoadingInProgressCount()
    }
    
    func hideLoadingIndicator(_ presenter: CompanyWorkplacePresenter) {
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
