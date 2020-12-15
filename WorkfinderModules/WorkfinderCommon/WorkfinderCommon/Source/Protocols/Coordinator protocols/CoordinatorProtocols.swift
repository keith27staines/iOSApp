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
    func signIn(screenOrder: SignInScreenOrder, completion: @escaping (Bool) -> Void)
    func showRecommendation(uuid: F4SUUID?, applicationSource: ApplicationSource)
    func showProject(uuid: F4SUUID?, applicationSource: ApplicationSource)
    func showApplications(uuid: F4SUUID?)
    func showSearch()
    func updateBadges()
    func handleDeepLinkUrl(url: URL) -> Bool
    func handlePushNotification(_ pushNotification: PushNotification?)
    func registerDevice(token: Data)
    func requestPushNotifications(from viewController: UIViewController)
}

public protocol OnboardingCoordinatorDelegate : class {
    func shouldEnableLocation(_ :Bool)
}

public protocol OnboardingCoordinatorProtocol : Coordinating {
    var isFirstLaunch: Bool { get set }
    var delegate: OnboardingCoordinatorDelegate? { get set }
    var onboardingDidFinish: ((OnboardingCoordinatorProtocol) -> Void)? { get set }
}

public protocol CompanyCoordinatorParentProtocol : CoreInjectionNavigationCoordinatorProtocol {
    func showHome()
}

public protocol TabNavigating: AnyObject {
    func navigateToTab(tab: TabIndex)
}

public enum TabIndex : Int, CaseIterable {
    // The order of the cases will determine the order of the tabs on the tab bar
    case applications
    case home
    case recommendations
}

public protocol TabBarCoordinatorProtocol : CoreInjectionNavigationCoordinatorProtocol, TabNavigating {
    func showApplicationsTab(uuid: F4SUUID?)
    func showHomeTab()
    func dispatchRecommendationToSearchTab(uuid: F4SUUID)
    func dispatchProjectViewRequest(_ projectUuid: F4SUUID, applicationSource: ApplicationSource)
    func updateBadges()
    func toggleMenu(completion: ((Bool) -> ())?)
    func updateUnreadMessagesCount(_ count: Int)
    var shouldAskOperatingSystemToAllowLocation: Bool { get set }
}

public protocol CoreInjectionProtocol : class {
    var networkConfig: NetworkConfig { get set }
    var appCoordinator: AppCoordinatorProtocol? { get set }
    var launchOptions: LaunchOptions? { get set }
    var user: Candidate { get set }
    var userRepository: UserRepositoryProtocol { get }
    var log: F4SAnalyticsAndDebugging { get }
    var versionChecker: WorkfinderVersionCheckerProtocol { get }
}

public protocol CoreInjectionNavigationCoordinatorProtocol : NavigationCoordinating {
    var injected: CoreInjectionProtocol { get }
}

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

public protocol RoutingProtocol: class {
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
        coordinator.parentCoordinator = self
    }
    func removeChildCoordinator(_ coordinator: Coordinating) {
        childCoordinators[coordinator.uuid] = nil
        coordinator.parentCoordinator = nil
    }
}




