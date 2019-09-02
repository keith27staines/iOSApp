//
//  UserDetailsCoordinator.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 25/05/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

class UserDetailsCoordinator : CoreInjectionNavigationCoordinator {
 
    let applicationContext: F4SApplicationContext
    
    var didFinish: ((UserDetailsCoordinator) -> Void)?
    var userIsTooYoung: (() -> Void)?
    var popOnCompletion: Bool = false
    
    weak var userDetailsViewController: UserDetailsViewController? = nil
    
    override func start() {
        let userDetailsStoryboard = UIStoryboard(name: "UserDetails", bundle: nil)
        let userDetailsViewController = userDetailsStoryboard.instantiateViewController(withIdentifier: "UserDetailsViewController") as! UserDetailsViewController
        let userInfo = applicationContext.user!.extractUserInformation()
        let viewModel = UserDetailsViewModel(userInformation: userInfo, coordinator: self)
        userDetailsViewController.coordinator = self
        userDetailsViewController.inject(viewModel: viewModel, applicationContext: applicationContext, userRepository: injected.userRepository)
        navigationRouter.push(viewController: userDetailsViewController, animated: true)
        self.userDetailsViewController = userDetailsViewController
    }
    
    func userDetailsDidComplete() {
        if popOnCompletion { navigationRouter.pop(animated: false) }
        parentCoordinator?.childCoordinatorDidFinish(self)
        didFinish?(self)
    }
    
    init(parent: Coordinating?,
         navigationRouter: NavigationRoutingProtocol,
         inject: CoreInjectionProtocol,
         applicationContext: F4SApplicationContext) {
        self.applicationContext = applicationContext
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
}
