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

protocol CompanyCoordinatorProtocol : CoreInjectionNavigationCoordinatorProtocol {}

class CompanyCoordinator : CoreInjectionNavigationCoordinator, CompanyCoordinatorProtocol {
    
    lazy var placementService: WEXPlacementServiceProtocol = { return WEXPlacementService() }()
    var companyViewController: CompanyViewController!
    var companyViewModel: CompanyViewModel!
    var company: Company
    
    init(
        parent: ApplyCoordinatorCoordinating?,
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
    
    func companyViewModel(_ viewModel: CompanyViewModel, applyTo companyViewData: CompanyViewData) {
        let viewData = CompanyViewData(company: company)
        startApplyCoordinator(companyViewData: viewData)
    }
    
    func startApplyCoordinator(companyViewData: CompanyViewData) {
        let applyCoordinator = ApplyCoordinator(
            company: companyViewData,
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

extension CompanyCoordinator :  ApplyCoordinatorCoordinating {
    func continueApplicationFromPlacementInAppliedState(_ placementJson: WEXPlacementJson, takingOverFrom coordinator: Coordinating) {
        cleanup()
        (parentCoordinator as? ApplyCoordinatorCoordinating)?.continueApplicationFromPlacementInAppliedState(placementJson, takingOverFrom: self)
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
}

struct CompanyCoordinatorFactory {
    func makeCompanyCoordinator(
        parent: ApplyCoordinatorCoordinating?,
        navigationRouter: NavigationRoutingProtocol,
        company: Company,
        inject: CoreInjectionProtocol) -> CompanyCoordinatorProtocol {
        return CompanyCoordinator(parent: parent, navigationRouter: navigationRouter, company: company, inject: inject)
    }
}
