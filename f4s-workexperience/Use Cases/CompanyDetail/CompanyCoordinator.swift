//
//  CompanyCoordinator.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 21/01/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import UIKit
import Reachability
import WorkfinderCommon
import WorkfinderNetworking
import WorkfinderServices

protocol CompanyCoordinatorProtocol : CoreInjectionNavigationCoordinatorProtocol {}

class CompanyCoordinator : CoreInjectionNavigationCoordinator, CompanyCoordinatorProtocol {
    
    lazy var placementService: WEXPlacementServiceProtocol = { return WEXPlacementService() }()
    var companyViewController: CompanyViewController!
    var companyViewModel: CompanyViewModel!
    var company: Company
    
    init(
        parent: CoreInjectionNavigationCoordinator?,
        navigationRouter: NavigationRoutingProtocol,
        company: Company,
        inject: CoreInjectionProtocol) {
        self.company = company
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    lazy var templateService: F4STemplateServiceProtocol = { return F4STemplateService() }()
    
    override func start() {
        super.start()
        companyViewModel = CompanyViewModel(coordinatingDelegate: self, company: company, people: [])
        companyViewController = CompanyViewController(viewModel: companyViewModel)
        navigationRouter.push(viewController: companyViewController, animated: true)
    }
    
    deinit {
        print("*************** Company coordinator was deinitialized")
    }
}

extension CompanyCoordinator : ApplyCoordinatorDelegate {
    func applicationDidFinish(preferredDestination: ApplyCoordinator.PreferredDestinationAfterApplication) {
        cleanup()
        navigationRouter.pop(animated: true)
        parentCoordinator?.childCoordinatorDidFinish(self)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) {
            switch preferredDestination {
            case .messages:
                TabBarCoordinator.sharedInstance!.navigateToTimeline()
            case .search:
                TabBarCoordinator.sharedInstance!.navigateToMap()
            case .none:
                break
            }
        }
    }
    func applicationDidCancel() {
        cleanup()
        navigationRouter.pop(animated: true)
    }
}

extension CompanyCoordinator : CompanyViewModelCoordinatingDelegate {

    func companyViewModelDidComplete(_ viewModel: CompanyViewModel) {
        cleanup()
        navigationRouter.pop(animated: true)
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
    
    func cleanup() {
        companyViewController = nil
        companyViewModel = nil
        childCoordinators = [:]
    }
    
    func companyViewModel(_ viewModel: CompanyViewModel, applyTo companyViewData: CompanyViewData, continueFrom placement: F4STimelinePlacement?) {
        let viewData = CompanyViewData(company: company)
        startApplyCoordinator(companyViewData: viewData, continueFrom: placement)
    }
    
    func startApplyCoordinator(companyViewData: CompanyViewData,
                               continueFrom: F4STimelinePlacement?) {
        let applyCoordinator = ApplyCoordinator(
            applyCoordinatorDelegate: self,
            company: company,
            placement: company.placement,
            parent: self,
            navigationRouter: navigationRouter,
            inject: injected,
            placementService: placementService,
            templateService: templateService)
        addChildCoordinator(applyCoordinator)
        applyCoordinator.start()
    }
    
    func companyViewModel(_ viewModel: CompanyViewModel, requestsShowLinkedIn person: PersonViewData) {
        print("Show linkedIn profile for \(person.fullName)")
    }
    
    func companyViewModel(_ viewModel: CompanyViewModel, requestsShowLinkedIn company: CompanyViewData) {
        openUrl(company.linkedinUrl)
    }
    
    func companyViewModel(_ viewModel: CompanyViewModel, requestedShowDuedil company: CompanyViewData) {
        openUrl(company.duedilUrl)
    }
    
    func companyViewModel(_ viewModel: CompanyViewModel, showShare company: CompanyViewData) {
        let socialShareData = SocialShareItemSource()
        socialShareData.company = self.company
        let activityViewController = UIActivityViewController(activityItems: [socialShareData], applicationActivities: nil)
        companyViewController.present(activityViewController, animated: true, completion: nil)
    }
}

struct CompanyCoordinatorFactory {
    func makeCompanyCoordinator(
        parent: CoreInjectionNavigationCoordinator?,
        navigationRouter: NavigationRoutingProtocol,
        company: Company,
        inject: CoreInjectionProtocol) -> CompanyCoordinatorProtocol {
        return CompanyCoordinator(parent: parent, navigationRouter: navigationRouter, company: company, inject: inject)
    }
}
