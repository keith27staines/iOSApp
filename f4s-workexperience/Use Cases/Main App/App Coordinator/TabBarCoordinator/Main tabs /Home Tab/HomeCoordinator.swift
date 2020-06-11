//
//  HomeCoordinator.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 15/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import UIKit
import WorkfinderCommon
import WorkfinderCoordinators

protocol HomeCoordinatorProtocol : CoreInjectionNavigationCoordinatorProtocol {}

class HomeCoordinator : CoreInjectionNavigationCoordinator, HomeCoordinatorProtocol {

    lazy var rootViewController: UIViewController = {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.red
        return vc
    }()
    
    override func start() {
        navigationRouter.navigationController.pushViewController(rootViewController, animated: false)
    }
}

protocol NotificationsCoordinatorProtocol : CoreInjectionNavigationCoordinatorProtocol {}

class NotificationsCoordinator : CoreInjectionNavigationCoordinator, HomeCoordinatorProtocol {

    lazy var rootViewController: UIViewController = {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.white
        vc.title = "Notifications"
        return vc
    }()
    
    override func start() {
        navigationRouter.navigationController.pushViewController(rootViewController, animated: false)
    }
}
