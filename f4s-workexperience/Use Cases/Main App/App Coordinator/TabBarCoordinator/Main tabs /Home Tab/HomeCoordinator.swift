//
//  HomeCoordinator.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 15/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import UIKit

protocol HomeCoordinatorProtocol : Coordinating {}

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
