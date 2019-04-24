//
//  NavigationRouter.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 16/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

class NavigationRouter : NavigationRoutingProtocol {
    let navigationController: UINavigationController
    var rootViewController: UIViewController
    
    func push(viewController: UIViewController, animated: Bool) {
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func popToViewController(_ viewController: UIViewController, animated: Bool) {
        navigationController.popToViewController(viewController, animated: animated)
    }
    
    func popToRootViewController(animated: Bool) {
        navigationController.popToRootViewController(animated: animated)
    }
    
    func pop(animated: Bool = true) {
        navigationController.popViewController(animated: true)
    }
    
    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        navigationController.present(viewController, animated: animated, completion: completion)
    }
    
    func dismiss(animated: Bool, completion: (() -> Void)?) {
        navigationController.dismiss(animated: animated, completion: nil)
    }
    
    
    init(navigationController: UINavigationController) {
        rootViewController = navigationController
        self.navigationController = navigationController
    }
}
