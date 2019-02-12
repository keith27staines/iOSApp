//
//  BaseCoordinator.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 21/01/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import UIKit

/// A convenient starting point for creating a coordinator
public class BaseCoordinator : Coordinating {
    
    let uuid: UUID = UUID()
    var parentCoordinator: Coordinating?
    let rootViewController: UIViewController
    var childCoordinators = [UUID : Coordinating]()
    
    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }
    
    func start() {}
    
    func openUrl(_ urlString: String?) { BaseCoordinator.openUrl(urlString) }
    func openUrl(_ url: URL?) { BaseCoordinator.openUrl(url) }
    
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
