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
    
    override func start() {
        let userDetailsStoryboard = UIStoryboard(name: "UserDetails", bundle: nil)
        let controller = userDetailsStoryboard.instantiateViewController(withIdentifier: "UserDetailsViewController") as! UserDetailsViewController
        let userInfo = applicationContext.user!.extractUserInformation()
        let viewModel = UserDetailsViewModel(userInformation: userInfo, coordinator: self)
        controller.coordinator = self
        controller.inject(viewModel: viewModel, applicationContext: applicationContext, userRepository: injected.userRepository)
        navigationRouter.push(viewController: controller, animated: true)
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
