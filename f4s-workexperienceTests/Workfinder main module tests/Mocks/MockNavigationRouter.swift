//
//  MockNavigationRouter.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 20/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
@testable import f4s_workexperience

class MockNavigationRouter : NavigationRoutingProtocol {
    func pop(animated: Bool) {
        
    }
    
    func popToViewController(_ viewController: UIViewController, animated: Bool) {
        
    }
    
    
    var navigationController: UINavigationController = UINavigationController()
    
    func push(viewController: UIViewController, animated: Bool = false) {
        pushedViewControllers.append(viewController)
    }
    
    func present(_ viewController: UIViewController, animated: Bool = false, completion: (() -> Void)? = nil) {
        presentedViewControllers.append(viewController)
    }
    
    func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        guard presentedViewControllers.count > 0 else { return }
        presentedViewControllers.removeLast()
    }
    
    var rootViewController: UIViewController = UIViewController()
    var pushedViewControllers = [UIViewController]()
    var presentedViewControllers = [UIViewController]()
    var dismissCount: Int = 0
    
    func pop() {
        pushedViewControllers.removeLast()
    }
}




