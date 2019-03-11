//
//  CompanyCoordinator.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 21/01/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import UIKit
import Reachability

protocol CompanyCoordinatorProtocol : Coordinating {}

class CompanyCoordinator : NavigationCoordinator, CompanyCoordinatorProtocol {
    
    var placementService: F4SPlacementServiceProtocol!
    var companyViewController: CompanyViewController!
    var companyViewModel: CompanyViewModel!
    let company: Company
    
    init(parent: Coordinating?, navigationRouter: NavigationRoutingProtocol, company: Company) {
        self.company = company
        super.init(parent: parent, navigationRouter: navigationRouter)
    }
    
    override func start() {
        super.start()
        placementService = F4SPlacementService()
        companyViewModel = CompanyViewModel(coordinatingDelegate: self, company: company, people: [])
        companyViewController = CompanyViewController(viewModel: companyViewModel)
        navigationRouter.present(companyViewController, animated: true, completion: nil)
    }

    func presentNotificationPopover() {
        let popOverVC = UIStoryboard(name: "NotificationView", bundle: nil).instantiateViewController(withIdentifier: "NotificationCtrl") as! NotificationViewController

        popOverVC.didComplete = { [unowned self] in
            self.companyViewController.dismiss(animated: true, completion: {
                self.presentCoveringLetter()
            })
        }
        popOverVC.currentCompany = company
        companyViewController.addChild(popOverVC)
        
        let popoverNavigationController = UINavigationController(rootViewController: popOverVC)
        popoverNavigationController.modalPresentationStyle = .popover
        
        let popover = popoverNavigationController.popoverPresentationController
        popover?.canOverlapSourceViewRect = true
        
        popOverVC.navigationController?.isNavigationBarHidden = true
        popOverVC.preferredContentSize = CGSize(width: popOverVC.view.frame.width - 40, height: popOverVC.contentLabel.frame.size.height + popOverVC.getHeight())
        
        popover?.sourceView = companyViewController.view
        popover?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        popover?.sourceRect = CGRect(x: companyViewController.view.bounds.midX, y: companyViewController.view.bounds.midY, width: 0, height: 0)
        popover?.delegate = popOverVC as NotificationViewController
        companyViewController.present(popoverNavigationController, animated: true, completion: nil)
    }
    
    func finish() {
        placementService = nil
        navigationRouter.dismiss(animated: true, completion: nil)
        companyViewController = nil
        companyViewModel = nil
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
    
    deinit {
        print("*************** Company coordinator was deinitialized")
    }
}

extension CompanyCoordinator : CompanyViewModelCoordinatingDelegate {

    func companyViewModelDidComplete(_ viewModel: CompanyViewModel) {
        finish()
    }
    
    func companyViewModel(_ viewModel: CompanyViewModel, applyTo: CompanyViewData) {
        guard let companyViewController = companyViewController else { fatalError("expected vc does not exist") }
        
        if let reachability = Reachability() {
            if !reachability.isReachableByAnyMeans {
                MessageHandler.sharedInstance.display("No Internet Connection.", parentCtrl: companyViewController)
                return
            }
        }
        //defer { finish() }
        guard company.placement == nil else {
            presentCoveringLetter()
            return
        }
        
        createPlacement(viewController: companyViewController, company: company) { [weak self] in
            guard let strongSelf = self else { return }
            if UNService.shared.userHasNotAgreedToNotifications {
                strongSelf.presentNotificationPopover()
            } else {
                strongSelf.presentCoveringLetter()
            }
        }
    }
    
    func presentCoveringLetter() {
        TabBarCoordinator.sharedInstance.presentCoverLetterController(parentCtrl: companyViewController, currentCompany: company)
    }

    /// Prunes interests that no longer appear in the live database from the user's interest list
    /// - Returns: set of good interests
    /// - Attention: Interests not are removed from the user's record in the local coredata database
    func pruneUserInterests() -> F4SInterestSet {
        let userInterestSet = InterestDBOperations.sharedInstance.interestsForCurrentUser()
        let allInterestsArray = InterestDBOperations.sharedInstance.getAllInterests()
        let allInterestsSet = Set(allInterestsArray)
        let union = userInterestSet.union(allInterestsSet)
        let badInterests = userInterestSet.subtracting(union)
        badInterests.forEach {
            InterestDBOperations.sharedInstance.removeUserInterestWithUuid($0.uuid)
        }
        return union
    }
    
    func createPlacement(viewController: UIViewController, company: Company, success: @escaping () -> Void) {
        let prunedInteresSet = pruneUserInterests()
        let interestList: [F4SInterest] = [F4SInterest](prunedInteresSet)
        MessageHandler.sharedInstance.showLoadingOverlay(viewController.view)
        var placement = F4SPlacement(
            userUuid: F4SUser().uuid,
            companyUuid: company.uuid,
            interestList: interestList)
        
        placementService.createPlacement(placement: placement) { (result) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                MessageHandler.sharedInstance.hideLoadingOverlay()
                switch result {
                case .error(let error):
                    if error.httpStatusCode == 409 {
                        MessageHandler.sharedInstance.display("You have already applied to this company on another device", parentCtrl: viewController)
                    } else {
                        MessageHandler.sharedInstance.display(error, parentCtrl: viewController, cancelHandler: nil, retryHandler: {
                            strongSelf.createPlacement(viewController: viewController, company: company, success: success)
                        })
                    }
                    
                case .success(let result):
                    placement.placementUuid = result.placementUuid
                    placement.status = F4SPlacementStatus.draft
                    PlacementDBOperations.sharedInstance.savePlacement(placement: placement)
                    success()
                }
            }
        }
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
        parent: Coordinating?,
        navigationRouter: NavigationRoutingProtocol,
        company: Company) -> CompanyCoordinatorProtocol {
        return CompanyCoordinator(parent: parent, navigationRouter: navigationRouter, company: company)
    }
}
