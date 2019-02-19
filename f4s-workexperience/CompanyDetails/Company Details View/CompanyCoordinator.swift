//
//  CompanyCoordinator.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 21/01/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import UIKit
import Reachability

class CompanyCoordinator : BaseCoordinator {
    
    var companyViewController: CompanyViewController!
    var navigationController: UINavigationController!
    var companyViewModel: CompanyViewModel!
    let company: Company
    
    init(rootViewController: UIViewController, company: Company) {
        self.company = company
        super.init(rootViewController: rootViewController)
    }
    
    
    
    var placementService: F4SPlacementServiceProtocol!
    
    override func start() {
        super.start()
        placementService = F4SPlacementService()
        companyViewModel = CompanyViewModel(coordinatingDelegate: self, company: company, people: [])
        companyViewController = CompanyViewController(viewModel: companyViewModel)
        navigationController = UINavigationController(rootViewController: companyViewController!)
        rootViewController.present(navigationController, animated: true, completion: nil)
    }
    
    func finish() {
        placementService = nil
        rootViewController.dismiss(animated: true, completion: nil)
        navigationController = nil
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
            presentCoveringLetter(presentingViewController: companyViewController, company: company)
            return
        }
        
        createPlacement(viewController: companyViewController, company: company) { [weak self] in
            guard let strongSelf = self else { return }
            if UNService.shared.userHasNotAgreedToNotifications {
                CustomNavigationHelper.sharedInstance.presentNotificationPopover(parentCtrl: companyViewController, currentCompany: strongSelf.company)
            } else {
                strongSelf.presentCoveringLetter(presentingViewController: companyViewController, company: strongSelf.company)
            }
        }
    }
    
    func presentCoveringLetter(presentingViewController: UIViewController, company: Company) {
        CustomNavigationHelper.sharedInstance.presentCoverLetterController(parentCtrl: presentingViewController, currentCompany: company)
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
            userUuid: F4SUser.userUuidFromKeychain,
            companyUuid: company.uuid,
            interestList: interestList)
        
        placementService.createPlacement(placement: placement) { (result) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                switch result {
                case .error(let error):
                    MessageHandler.sharedInstance.hideLoadingOverlay()
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
        let excludeActivities = [
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.copyToPasteboard,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.airDrop,
            UIActivity.ActivityType.openInIBooks,
            ]
        activityViewController.excludedActivityTypes = excludeActivities
        self.navigationController?.present(activityViewController, animated: true, completion: nil)
    }
}
