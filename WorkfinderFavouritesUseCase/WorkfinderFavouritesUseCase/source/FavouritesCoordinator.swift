//
//  FavouritesCoordinator.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 02/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderCoordinators
import WorkfinderCompanyDetailsUseCase

let __bundle = Bundle(identifier: "com.f4s.WorkfinderFavouritesUseCase")
let __maximumNumberOfFavourites = 20

public class FavouritesCoordinator : CoreInjectionNavigationCoordinator {
    
    lazy var rootViewController: FavouriteViewController = {
        let storyboard = UIStoryboard(name: "Favourite", bundle: __bundle)
        return storyboard.instantiateViewController(withIdentifier: "FavouriteViewCtrl") as! FavouriteViewController
    }()
    
    let companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol
    public init(parent: CompanyCoordinatorParentProtocol?,
         navigationRouter: NavigationRoutingProtocol,
         inject: CoreInjectionProtocol,
         companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol) {
        self.companyCoordinatorFactory = companyCoordinatorFactory
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    public override func start() {
        rootViewController.coordinator = self
        navigationRouter.navigationController.pushViewController(rootViewController, animated: false)
    }
    
    var company: Company?
    
    func showDetail(company: Company?) {
        self.company = company
        guard let company = company else { return }
        rootViewController.dismiss(animated: true)
        let companyCoordinator = companyCoordinatorFactory.makeCompanyCoordinator(parent: self, navigationRouter: navigationRouter, company: company, inject: injected)
        addChildCoordinator(companyCoordinator)
        companyCoordinator.start()
    }
}

extension FavouritesCoordinator: CompanyCoordinatorParentProtocol {
    public func showMessages() {
        (parentCoordinator as? CompanyCoordinatorParentProtocol)?.showMessages()
    }
    
    public func showSearch() {
        (parentCoordinator as? CompanyCoordinatorParentProtocol)?.showSearch()
    }
}
