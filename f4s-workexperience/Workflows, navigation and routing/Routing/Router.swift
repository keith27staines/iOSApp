//
//  Router.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 16/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

public protocol RoutingProtocol {
    var rootViewController: UIViewController { get }
    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    func dismiss(animated: Bool, completion: (() -> Void)?)
}

public protocol NavigationRoutingProtocol : RoutingProtocol {
    var navigationController: UINavigationController { get }
    func push(viewController: UIViewController, animated: Bool)
    func pop()
}
