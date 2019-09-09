//
//  NavigationCoordinator.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 21/01/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import UIKit
import WorkfinderCommon

/// A convenient starting point for creating a coordinator that uses a UINavigationController
open class NavigationCoordinator : Coordinating {
    
    public var navigationRouter: NavigationRoutingProtocol
    public let uuid: UUID = UUID()
    public var parentCoordinator: Coordinating?
    public var childCoordinators = [UUID : Coordinating]()
    
    public init(parent: Coordinating?, navigationRouter: NavigationRoutingProtocol) {
        self.navigationRouter = navigationRouter
        self.parentCoordinator = parent
    }
    open func start() {}
}

// MARK:- Support opening URLs
public extension NavigationCoordinator {
    func openUrl(_ urlString: String?) { NavigationCoordinator.openUrl(urlString) }
    func openUrl(_ url: URL?) { NavigationCoordinator.openUrl(url) }
    
    static func openUrl(_ urlString: String?) {
        guard let urlString = urlString else { return }
        openUrl(URL(string: urlString))
    }
    
    static func openUrl(_ url: URL?) {
        guard let url = url else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

