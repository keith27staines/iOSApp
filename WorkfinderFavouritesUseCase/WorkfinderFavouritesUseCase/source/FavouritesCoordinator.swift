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
    
    var company: Company?
    let companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol
    let placementsRepository: F4SPlacementRepositoryProtocol
    let favouritesRepository: F4SFavouritesRepositoryProtocol
    let companyRepository: F4SCompanyRepositoryProtocol
    
    lazy var rootViewController: FavouriteViewController = {
        let storyboard = UIStoryboard(name: "Favourite", bundle: __bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "FavouriteViewCtrl") as! FavouriteViewController
        vc.log = self.injected.log
        return vc
    }()
    
    weak var tabBarCoordinator: TabBarCoordinatorProtocol?
    
    public init(parent: TabBarCoordinatorProtocol,
         navigationRouter: NavigationRoutingProtocol,
         inject: CoreInjectionProtocol,
         companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol,
         placementsRepository: F4SPlacementRepositoryProtocol,
         favouritesRepository: F4SFavouritesRepositoryProtocol,
         companyRepository: F4SCompanyRepositoryProtocol) {
        self.tabBarCoordinator = parent
        self.companyCoordinatorFactory = companyCoordinatorFactory
        self.placementsRepository = placementsRepository
        self.favouritesRepository = favouritesRepository
        self.companyRepository = companyRepository
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    public override func start() {
        rootViewController.coordinator = self
        rootViewController.placementsRepository = placementsRepository
        rootViewController.favouritesRepository = favouritesRepository
        rootViewController.companyRepository = companyRepository
        navigationRouter.navigationController.pushViewController(rootViewController, animated: false)
    }
    
    func showDetail(company: Company?) {
        injected.log.track(event: .favouritesShowCompanyTap, properties: nil)
        self.company = company
        guard let company = company else { return }
        let originScreen = rootViewController.screenName
        rootViewController.dismiss(animated: true)
        let companyCoordinator = companyCoordinatorFactory.makeCompanyCoordinator(parent: self, navigationRouter: navigationRouter, company: company, inject: injected)
        companyCoordinator.originScreen = originScreen
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

extension FavouritesCoordinator {
    func toggleMenu() {
        tabBarCoordinator?.toggleMenu(completion: nil)
    }
}
