//
//  CompanyMainViewController.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 21/01/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import UIKit

class CompanyViewController: UIViewController {
    
    let viewModel: CompanyViewModel
    
    init(viewModel: CompanyViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.viewModelDelegate = self
    }
    
    private var loadingInProgressCount: Int = 0
    
    func refresh() {
        companyMainPageView.refresh()
    }
    
    lazy var pageViewController: CompanyPageViewController = {
        let pageViewController = CompanyPageViewController(viewModel: viewModel)
        pageViewController.willMove(toParent: self)
        companyMainPageView.addPageControllerView(view: pageViewController.view)
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        return pageViewController
    }()
    
    lazy var companyMainPageView: CompanyMainView = view as! CompanyMainView
    
    override func loadView() {
        view = CompanyMainView(companyViewModel: viewModel, delegate: self)
    }
    
    override func viewDidLoad() {
        _ = pageViewController
        companyMainPageView.segmentedControl.selectedSegmentIndex = viewModel.selectedPersonIndex ?? 0
        viewModel.userLocation = companyMainPageView.mapView.userLocation.location
        refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        refresh()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func incrementLoadingInProgressCount() {
        if loadingInProgressCount == 0 {
            MessageHandler.sharedInstance.showLightLoadingOverlay(view)
        }
        loadingInProgressCount += 1
    }
    
    func decrementLoadingInProgressCount() {
        if loadingInProgressCount == 1 {
            MessageHandler.sharedInstance.hideLoadingOverlay()
            refresh()
        }
        if loadingInProgressCount > 0 {
            loadingInProgressCount -= 1
        }
    }
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
    }
}

extension CompanyViewController : CompanyMainViewDelegate {
    func companyMainViewDidTapApply(_ view: CompanyMainView) {
        let initiateApplyResult = viewModel.didTapApply()
        processInitiateApplyResult(initiateApplyResult)
    }
    
    func companyMainViewDidTapDone(_ view: CompanyMainView) {
        viewModel.didTapDone()
    }
    
    func companyMainView(_ view: CompanyMainView, didSelectPage page: CompanyViewModel.PageIndex?) {
        pageViewController.moveToPage(index: page)
    }
    
    func companyToolbar(_ toolbar: CompanyToolbar, requestedAction: CompanyToolbar.ActionType) {
        switch requestedAction {
        case .showShare:
            viewModel.showShare()
        case .toggleHeart:
            incrementLoadingInProgressCount()
            viewModel.toggleFavourited()
        case .showMap:
            viewModel.isShowingMap.toggle()
        }
    }
    
    func processInitiateApplyResult(_ applyState: CompanyViewModel.InitiateApplicationResult) {
        let title = applyState.deniedReason?.title
        let message = applyState.deniedReason?.message
        let buttonTitle = applyState.deniedReason?.buttonTitle
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var handler: ((UIAlertAction) -> (Void))? = nil
        let action: UIAlertAction
        switch applyState {
        case .allowed:
            return
        case .deniedMustSelectPerson:
            handler = { alertAction in
                let segmentedControl = self.companyMainPageView.segmentedControl
                segmentedControl.selectedSegmentIndex = 0
                // TODO: enable peopple tab: uncomment next line
                // self.pageViewController.moveToPage(index: CompanyViewModel.PageIndex.people)
            }
        case .deniedAlreadyApplied:
            break
        case .deniedCompanyNoAcceptingApplications:
            break
        }
        action = UIAlertAction(title: buttonTitle, style: UIAlertAction.Style.cancel, handler: handler)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
