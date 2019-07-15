//
//  VersionCheckCoordinator.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 08/07/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import WorkfinderCommon

protocol VersionChecking {
    var versionCheckCompletion: ((F4SNetworkResult<F4SVersionValidity>) -> Void)? { get set }
}

/// `VersionCheckCoordinator` uses its `versionCheckingService` to determine if
/// the current app version should be forced to update. This is a reusable
/// coordinator assuming that the result of the check is that the app doesn't
/// need to be updated, so `start` can be called as often as desired
///
/// If the app needs to be updated, then:
/// 1. This coordinator presents a view controller that guides the user to the
///    AppStore. The presented UI doesn't permit any other exit, so the user is forced to
///    update or close the app
/// 2. The coordinator calls back with the result of the version check using the
///    `versionCheckCompletion` closure
/// 3. This coordinator does NOT call `childCoordinatorDidFinish` on its parent
///
/// If the app doesn't need to be updated then:
/// 1. This coordinator calls back with the result of the version check using the
///    `versionCheckCompletion` closure
/// 2. Calls `childCoordinatorDidFinish` on its parent
class VersionCheckCoordinator: NavigationCoordinator, VersionChecking {
    
    /// This callback returns the result of the version check
    var versionCheckCompletion: ((F4SNetworkResult<F4SVersionValidity>) -> Void)?
    
    /// Service used to determine whether the app needs to be updated
    var versionCheckService: F4SWorkfinderVersioningServiceProtocol?
    
    /// Starts the version check. This method can be called again if the
    /// `versionCheckCompletion` callback returns a positive result or an error
    /// but should not be called again if the callback returns a negative result
    override func start() {
        versionCheckService?.getIsVersionValid(completion: { (result) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let isValid):
                    if isValid {
                        strongSelf.parentCoordinator?.childCoordinatorDidFinish(strongSelf)
                    } else {
                        strongSelf.forceUpdate()
                    }
                case .error(_): break
                }
                strongSelf.versionCheckCompletion?(result)
            }
        })
    }
    
    /// Presents UI to guide the user to the appstore to update the app
    ///
    /// The presented UI doesn't permit any other exit, so the user is forced to
    /// update or close the app
    func forceUpdate() {
        let forceUpdateVC = F4SForceAppUpdateViewController()
        navigationRouter.present(forceUpdateVC, animated: true, completion: nil)
    }
}
