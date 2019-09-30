//
//  CoordinatorProtocols.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 18/09/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

public protocol AppCoordinatorProtocol : Coordinating {
    var window: UIWindow { get }
    var log: F4SAnalyticsAndDebugging { get }
    func performVersionCheck(resultHandler: @escaping ((F4SNetworkResult<F4SVersionValidity>)->Void))
    func showRecommendations()
    func showMessages()
    func showSearch()
    func updateBadges()
    func handleRemoteNotification(userInfo: [AnyHashable: Any])
}

public protocol RemoteNotificationsRegistrarProtocol {
    func registerForRemoteNotifications()
}

public protocol CompanyCoordinatorProtocol : CoreInjectionNavigationCoordinatorProtocol {}

public protocol CompanyCoordinatorFactoryProtocol {
    func makeCompanyCoordinator(
        parent: CompanyCoordinatorParentProtocol,
        navigationRouter: NavigationRoutingProtocol,
        inject: CoreInjectionProtocol,
        companyUuid: F4SUUID) ->  CompanyCoordinatorProtocol?
    
    func makeCompanyCoordinator(
        parent: CompanyCoordinatorParentProtocol,
        navigationRouter: NavigationRoutingProtocol,
        company: Company,
        inject: CoreInjectionProtocol) -> CompanyCoordinatorProtocol
}

public protocol OnboardingCoordinatorDelegate : class {
    func shouldEnableLocation(_ :Bool)
}

public protocol OnboardingCoordinatorProtocol : Coordinating {
    var hideOnboardingControls: Bool { get set }
    var delegate: OnboardingCoordinatorDelegate? { get set }
    var onboardingDidFinish: ((OnboardingCoordinatorProtocol) -> Void)? { get set }
}

public protocol CompanyCoordinatorParentProtocol : CoreInjectionNavigationCoordinatorProtocol {
    func showMessages()
    func showSearch()
}

public protocol TabBarCoordinatorProtocol : CoreInjectionNavigationCoordinatorProtocol {
    func showSearch()
    func showMessages()
    func showRecommendations()
    func updateBadges()
    func toggleMenu(completion: ((Bool) -> ())?)
    func updateUnreadMessagesCount(_ count: Int)
    var shouldAskOperatingSystemToAllowLocation: Bool { get set }
}

public protocol CoreInjectionProtocol : class {
    var appCoordinator: AppCoordinatorProtocol? { get set }
    var appInstallationUuidLogic: AppInstallationUuidLogicProtocol { get }
    var launchOptions: LaunchOptions? { get set }
    var user: F4SUser { get set }
    var userService: F4SUserServiceProtocol { get }
    var userStatusService: F4SUserStatusServiceProtocol { get }
    var userRepository: F4SUserRepositoryProtocol { get }
    var databaseDownloadManager: F4SDatabaseDownloadManagerProtocol { get }
    var contentService: F4SContentServiceProtocol { get }
    var log: F4SAnalyticsAndDebugging { get }
}

public protocol CoreInjectionNavigationCoordinatorProtocol : NavigationCoordinating {
    var injected: CoreInjectionProtocol { get }
}

public protocol VersionChecking : class {
    var versionCheckCompletion: ((F4SNetworkResult<F4SVersionValidity>) -> Void)? { get set }
}

public protocol VersionCheckCoordinatorProtocol: NavigationCoordinating, VersionChecking {}

public protocol NavigationCoordinating : Coordinating {}

public protocol Coordinating : class {
    
    var parentCoordinator: Coordinating? { get set }
    var uuid: UUID { get }
    var childCoordinators: [UUID: Coordinating] { get set }
    func addChildCoordinator(_ coordinator: Coordinating)
    func removeChildCoordinator(_ coordinator: Coordinating)
    
    func start()
    func childCoordinatorDidFinish(_ coordinator: Coordinating)
}

public protocol NavigationRoutingProtocol : RoutingProtocol {
    var navigationController: UINavigationController { get }
    func push(viewController: UIViewController, animated: Bool)
    func pop(animated: Bool)
    func popToViewController(_ viewController: UIViewController, animated: Bool)
}

public protocol RoutingProtocol {
    var rootViewController: UIViewController { get }
    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    func dismiss(animated: Bool, completion: (() -> Void)?)
}

public extension Coordinating {
    
    func childCoordinatorDidFinish(_ coordinator: Coordinating) {
        removeChildCoordinator(coordinator)
    }
    
    func addChildCoordinator(_ coordinator: Coordinating) {
        childCoordinators[coordinator.uuid] = coordinator
    }
    func removeChildCoordinator(_ coordinator: Coordinating) {
        childCoordinators[coordinator.uuid] = nil
    }
}




