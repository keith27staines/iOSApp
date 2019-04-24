//
//  SearchCoordinator.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 02/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

class SearchCoordinator : CoreInjectionNavigationCoordinator, ApplyCoordinatorCoordinating {
    
    func continueApplicationFromPlacementInAppliedState(_ placementJson: WEXPlacementJson, takingOverFrom coordinator: Coordinating) {
        let user = F4SUser()
        let company = showingDetailForCompany!
        let availabilityPeriod = F4SAvailabilityPeriod(availabilityPeriodJson: placementJson.availabilityPeriods!.first!)
        let placement = F4SPlacement(
            userUuid: user.uuid,
            companyUuid: company.uuid,
            interestList: [],
            status: placementJson.workflowState,
            placementUuid: placementJson.uuid!)
        let applicationContext = F4SApplicationContext(
            user: user,
            company: company,
            placement: placement,
            availabilityPeriod: availabilityPeriod)
        TabBarCoordinator.sharedInstance.pushProcessedMessages(navigationRouter.navigationController, applicationContext: applicationContext)
    }
    
    var shouldAskOperatingSystemToAllowLocation = false
    
    lazy var rootViewController: MapViewController = {
        let storyboard = UIStoryboard(name: "MapView", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MapViewCtrl") as! MapViewController
        vc.coordinator = self
        return vc
    }()
    
    override func start() {
        rootViewController.coordinator = self
        rootViewController.shouldRequestAuthorization = shouldAskOperatingSystemToAllowLocation
        navigationRouter.navigationController.pushViewController(rootViewController, animated: false)
    }
    
    var showingDetailForCompany: Company?

    func showDetail(company: Company?) {
        guard let company = company else { return }
        showingDetailForCompany = company
        rootViewController.dismiss(animated: true)
        let companyCoordinator = CompanyCoordinator(parent: self, navigationRouter: navigationRouter, company: company, inject: injected)
        addChildCoordinator(companyCoordinator)
        companyCoordinator.start()
    }
    
    func filtersButtonWasTapped() {
        guard
            let unfilteredMapModel = rootViewController.unfilteredMapModel,
            let visibleMapBounds = rootViewController.visibleMapBounds else { return }
        let interestsStoryboard = UIStoryboard(name: "InterestsView", bundle: nil)
        let interestsViewController = interestsStoryboard.instantiateViewController(withIdentifier: "interestsCtrl") as! InterestsViewController
        interestsViewController.visibleBounds = visibleMapBounds
        interestsViewController.mapModel = unfilteredMapModel
        interestsViewController.delegate = rootViewController
        let navigationController = UINavigationController(rootViewController: interestsViewController)
        rootViewController.present(navigationController, animated: true, completion: nil)
   }
}
