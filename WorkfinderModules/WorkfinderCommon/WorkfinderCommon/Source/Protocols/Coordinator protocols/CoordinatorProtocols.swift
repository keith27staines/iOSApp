//
//  CoordinatorProtocols.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 18/09/2019.
//  Copyright © 2019 Workfinder Ltd. All rights reserved.
//

import Foundation

public protocol AppCoordinatorProtocol : Coordinating {
    var window: UIWindow { get }
    var log: F4SAnalyticsAndDebugging { get }
    func signIn(screenOrder: SignInScreenOrder, completion: @escaping (Bool, PreferredNextScreen) -> Void)
    func routeInterviewInvite(uuid: F4SUUID?, appSource: AppSource)
    func routeRecommendation(recommendationUuid: F4SUUID?, appSource: AppSource)
    func routeProject(projectUuid: F4SUUID?, appSource: AppSource)
    func routeApplication(placementUuid: F4SUUID?, appSource: AppSource)
    func routeReview(reviewUuid: F4SUUID, appSource: AppSource, queryItems: [String: String])
    func routeLiveProjects(appSource: AppSource)
    func routeStudentsDashboard(appSource: AppSource)
    func switchToTab(_ tab: TabIndex)
    func updateBadges()
    func handleDeepLinkUrl(url: URL)
    func handlePushNotification(_ pushNotification: PushNotification?)
    func registerDevice(token: Data)
    func requestPushNotifications(from viewController: UIViewController, completion: @escaping () -> Void )
}

public protocol OnboardingCoordinatorDelegate : AnyObject {
}

public protocol OnboardingCoordinatorProtocol : Coordinating {
    var isOnboardingRequired: Bool { get }
    var delegate: OnboardingCoordinatorDelegate? { get set }
    var onboardingDidFinish: ((OnboardingCoordinatorProtocol, PreferredNextScreen) -> Void)? { get set }
}

public protocol CompanyCoordinatorParentProtocol : CoreInjectionNavigationCoordinatorProtocol {
    func switchToTab(_ tab: TabIndex)
}

public protocol TabNavigating: AnyObject {
    func switchToTab(_ tab: TabIndex)
}

public enum TabIndex : Int, CaseIterable {
    // The order of the cases will determine the order of the tabs on the tab bar    
    case recommendations
    case home
    case applications
    case account
}

public protocol TabBarCoordinatorProtocol : CoreInjectionNavigationCoordinatorProtocol, TabNavigating {
    func start(preferredScreen: PreferredNextScreen)
    func switchToTab(_ tab: TabIndex)
    func routeInterviewInvite(interviewUuid: F4SUUID?, appSource: AppSource)
    func routeApplication(placementUuid: F4SUUID?, appSource: AppSource)
    func routeRecommendationForAssociation(recommendationUuid: F4SUUID, appSource: AppSource)
    func routeProject(projectUuid: F4SUUID, appSource: AppSource)
    func routeReview(reviewUuid: F4SUUID, appSource: AppSource, queryItems:[String:String])
    func routeLiveProjects(appSource: AppSource)
    func updateBadges()
    func updateUnreadMessagesCount(_ count: Int)
}

public protocol CoreInjectionProtocol : AnyObject {
    var networkConfig: NetworkConfig { get set }
    var appCoordinator: AppCoordinatorProtocol? { get set }
    var launchOptions: LaunchOptions? { get set }
    var user: Candidate { get set }
    var userRepository: UserRepositoryProtocol { get }
    var log: F4SAnalyticsAndDebugging { get }
    var versionChecker: WorkfinderEnvironmentConsistencyCheckerProtocol { get }
    var requestAppReviewLogic: RequestAppReviewLogic { get }
}

public protocol CoreInjectionNavigationCoordinatorProtocol : NavigationCoordinating {
    var injected: CoreInjectionProtocol { get }
}

public protocol NavigationCoordinating : Coordinating {}

public protocol Coordinating : AnyObject {
    
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

public protocol RoutingProtocol: AnyObject {
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




