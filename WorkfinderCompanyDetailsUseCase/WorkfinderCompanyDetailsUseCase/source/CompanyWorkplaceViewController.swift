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

protocol CompanyWorkplaceViewProtocol : class {
    var presenter: CompanyWorkplacePresenterProtocol! { get set }
    func companyWorkplacePresenterDidRefresh(_ presenter: CompanyWorkplacePresenter)
    func companyWorkplacePresenterDidBeginNetworkTask(_ presenter: CompanyWorkplacePresenter)
    func companyWorkplacePresenterDidEndLoadingTask(_ presenter: CompanyWorkplacePresenter)
    func companyWorkplacePresenterDidFailNetworkTask(_ presenter: CompanyWorkplacePresenter, error: F4SNetworkError, retry: (() -> Void)?)
    func companyWorkplacePresenter(_ presenter: CompanyWorkplacePresenter, showMap: Bool)
}

class CompanyWorkplaceViewController: UIViewController {
    var presenter: CompanyWorkplacePresenterProtocol!
    weak var coordinator: CompanyCoordinatorProtocol!
    let screenName = ScreenName.company
    var originScreen = ScreenName.notSpecified
    weak var log: F4SAnalyticsAndDebugging?
    var appSettings: AppSettingProvider
    
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
            sharedUserMessageHandler.showLightLoadingOverlay(view)
        }
        loadingInProgressCount += 1
    }
    
    func decrementLoadingInProgressCount() {
        if loadingInProgressCount == 1 {
            sharedUserMessageHandler.hideLoadingOverlay()
            refresh()
        }
        if loadingInProgressCount > 0 {
            loadingInProgressCount -= 1
        }
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension CompanyWorkplaceViewController : CompanyWorkplaceViewProtocol{
    
    func companyWorkplacePresenter(_ viewModel: CompanyWorkplacePresenter, showMap: Bool) {
        switch showMap {
        case true:
            companyMainPageView.animateMapIn()
        case false:
            companyMainPageView.animateMapOut()
        }
    }
    
    func companyWorkplacePresenterDidFailNetworkTask(_ viewModel: CompanyWorkplacePresenter, error: F4SNetworkError, retry: (() -> Void)?) {
        let alert: UIAlertController = UIAlertController(title: "Network error", message: "The operation could not be completed", preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { [weak self] action in
            self?.decrementLoadingInProgressCount()
        })
        alert.addAction(cancelAction)
        if error.retry {
            let retryAction = UIAlertAction(title: "Retry", style: .default) { (action) in retry?() }
            alert.addAction(retryAction)
        }
        present(alert, animated: true, completion: nil)
    }
    
    func companyWorkplacePresenterDidRefresh(_ viewModel: CompanyWorkplacePresenter) {
        refresh()
    }
    
    func companyWorkplacePresenterDidBeginNetworkTask(_ viewModel: CompanyWorkplacePresenter) {
        incrementLoadingInProgressCount()
    }
    
    func companyWorkplacePresenterDidEndLoadingTask(_ viewModel: CompanyWorkplacePresenter) {
        decrementLoadingInProgressCount()
        refresh()
    }
}

extension CompanyWorkplaceViewController : CompanyMainViewCoordinatorProtocol {
    func companyMainViewDidTapApply(_ view: CompanyMainView) {
        presenter.onTapApply()
        
        /*
        presenter.onTapApply() { [weak self] (initiateApplyResult) in
            guard let strongSelf = self else { return }
            strongSelf.processInitiateApplyResult(initiateApplyResult)
        }
         */
    }
    
    func companyToolbar(_ toolbar: CompanyToolbar, requestedAction: CompanyToolbar.ActionType) {
        switch requestedAction {
        case .showMap:
            switch presenter.isShowingMap {
            case true:
                log?.track(event: .companyDetailsHideMapTap, properties: nil)
            case false:
                log?.track(event: .companyDetailsShowMapTap, properties: nil)
            }
            presenter.isShowingMap.toggle()
        }
    }
    
//    func processInitiateApplyResult(_ applyState: CompanyWorkplacePresenter.InitiateApplicationResult) {
//        let title = applyState.deniedReason?.title
//        let message = applyState.deniedReason?.message
//        let buttonTitle = applyState.deniedReason?.buttonTitle
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let handler: ((UIAlertAction) -> (Void))? = nil
//        let action: UIAlertAction
//        switch applyState {
//        case .allowed:
//            return
//        case .deniedAlreadyApplied:
//
//            break
//        }
//        action = UIAlertAction(title: buttonTitle, style: UIAlertAction.Style.cancel, handler: handler)
//        alert.addAction(action)
//        present(alert, animated: true, completion: nil)
//    }
}
