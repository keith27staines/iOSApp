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

class CompanyViewController: UIViewController {
    let screenName = ScreenName.company
    var originScreen = ScreenName.notSpecified
    let viewModel: CompanyViewModel
    weak var log: F4SAnalyticsAndDebugging?
    var appSettings: AppSettingProvider
    
    init(viewModel: CompanyViewModel, appSettings: AppSettingProvider) {
        self.viewModel = viewModel
        self.appSettings = appSettings
        super.init(nibName: nil, bundle: nil)
        viewModel.viewModelDelegate = self
        hidesBottomBarWhenPushed = true
    }
    
    private var loadingInProgressCount: Int = 0
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    func refresh() {
        viewModel.userLocation = companyMainPageView.mapView.userLocation.location
        companyMainPageView.refresh()
    }
    
    lazy var companyMainPageView: CompanyMainView = {
        let mainView = view as! CompanyMainView
        mainView.appSettings = self.appSettings
        mainView.log = log
        return mainView
    }()
    
    override func loadView() {
        view = CompanyMainView(companyViewModel: viewModel, delegate: self, appSettings: appSettings)
    }
    
    override func viewDidLoad() {
        log?.track(event: .companyDetailsScreenDidLoad, properties: nil)
        viewModel.viewModelDelegate = self
        viewModel.startLoad()
        refresh()
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
        button.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    func configureNavigationBar() {
        navigationController?.isNavigationBarHidden = false
        styleNavigationController()
        navigationItem.leftBarButtonItem = leftButton
    }
    
    @objc func didTapDone() {
        viewModel.didTapDone()
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

extension CompanyViewController : CompanyViewModelDelegate {
    
    func companyViewModel(_ viewModel: CompanyViewModel, showMap: Bool) {
        switch showMap {
        case true:
            companyMainPageView.animateMapIn()
        case false:
            companyMainPageView.animateMapOut()
        }
    }
    
    func companyViewModelNetworkTaskDidFail(_ viewModel: CompanyViewModel, error: F4SNetworkError, retry: (() -> Void)?) {
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
    
    func companyViewModelDidRefresh(_ viewModel: CompanyViewModel) {
        refresh()
    }
    
    func companyViewModelDidBeginNetworkTask(_ viewModel: CompanyViewModel) {
        incrementLoadingInProgressCount()
    }
    
    func companyViewModelDidCompleteLoadingTask(_ viewModel: CompanyViewModel) {
        decrementLoadingInProgressCount()
        refresh()
    }
}

extension CompanyViewController : CompanyMainViewDelegate {
    func companyMainViewDidTapApply(_ view: CompanyMainView) {
        viewModel.didTapApply { [weak self] (initiateApplyResult) in
            guard let strongSelf = self else { return }
            strongSelf.processInitiateApplyResult(initiateApplyResult)
        }
    }
    
    func companyToolbar(_ toolbar: CompanyToolbar, requestedAction: CompanyToolbar.ActionType) {
        switch requestedAction {
        case .showShare:
            log?.track(event: .companyDetailsShowShareTap, properties: nil)
            viewModel.showShare()
        case .toggleHeart:
            incrementLoadingInProgressCount()
            switch viewModel.isFavourited {
            case true:
                log?.track(event: .companyDetailsFavouriteSwitchOff, properties: nil)
            case false:
                log?.track(event: .companyDetailsFavouriteSwitchOn, properties: nil)
            }
            viewModel.toggleFavourited()
        case .showMap:
            switch viewModel.isShowingMap {
            case true:
                log?.track(event: .companyDetailsHideMapTap, properties: nil)
            case false:
                log?.track(event: .companyDetailsShowMapTap, properties: nil)
            }
            viewModel.isShowingMap.toggle()
        }
    }
    
    func processInitiateApplyResult(_ applyState: CompanyViewModel.InitiateApplicationResult) {
        let title = applyState.deniedReason?.title
        let message = applyState.deniedReason?.message
        let buttonTitle = applyState.deniedReason?.buttonTitle
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let handler: ((UIAlertAction) -> (Void))? = nil
        let action: UIAlertAction
        switch applyState {
        case .allowed:
            return
        case .deniedAlreadyApplied:
            
            break
        }
        action = UIAlertAction(title: buttonTitle, style: UIAlertAction.Style.cancel, handler: handler)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
