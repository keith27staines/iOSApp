
import Foundation

public class MockTabBarCoordinator : MockCoreInjectionNavigationCoordinator, TabBarCoordinatorProtocol {
    
    public func routeInterviewInvite(interviewUuid: F4SUUID?, appSource: AppSource) {
        
    }
    
    public func start(preferredScreen: PreferredNextScreen) {
        
    }
    
    public func routeLiveProjects(appSource: AppSource) {
        
    }
    
    public func routeReview(reviewUuid: F4SUUID, appSource: AppSource, queryItems: [String : String]) {
        
    }
    
    public func routeProject(projectUuid: F4SUUID, appSource: AppSource) {
        
    }
    
    public func switchToTab(_ tab: TabIndex) {
        
    }
    
    public func navigateToRecommendations() {}
    
    var showApplicationsCallCount: Int = 0
    public func routeApplication(placementUuid: F4SUUID?, appSource: AppSource) {
        
    }
    
    var dispatchRecommendationToSearchTabCount = 0
    public func routeRecommendationForAssociation(recommendationUuid: F4SUUID, appSource: AppSource) {
        dispatchRecommendationToSearchTabCount += 1
    }
    
    var updateBadgesCallCount = 0
    public func updateBadges() {
        updateBadgesCallCount += 1
    }
    
    var showSearchCallCount: Int = 0
    public func showHomeTab() {
        showSearchCallCount += 1
    }
    
    var showMessagesCallCount: Int = 0
    public func showMessages() {
        showMessagesCallCount += 1
    }
    
    var updateUnreadMessagesCallCount: Int = 0
    public func updateUnreadMessagesCount(_ count: Int) {
        updateUnreadMessagesCallCount += 1
    }
    
    var menuOpen: Bool = false
    public func toggleMenu(completion: ((Bool) -> ())?) {
        menuOpen.toggle()
        completion?(menuOpen)
    }
    
    public required init(parent: Coordinating?, navigationRouter: NavigationRoutingProtocol, inject: CoreInjectionProtocol) {
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
}

public class MockParentCoordinator: Coordinating {
    
    public var parentCoordinator: Coordinating? = nil
    public var uuid: UUID = UUID()
    public var childCoordinators = [UUID : Coordinating]()
    var router: NavigationRoutingProtocol
    public init(router: NavigationRoutingProtocol) {
        self.router = router
    }
    
    public func start() {}
    
}

public class MockCoreInjectionNavigationCoordinator : CoreInjectionNavigationCoordinatorProtocol {
    
    public var parentCoordinator: Coordinating?
    public var uuid: UUID = UUID()
    public var childCoordinators = [UUID : Coordinating]()
    public var injected: CoreInjectionProtocol
    var navigationRouter: NavigationRoutingProtocol
    
    public private (set) var startedCount: Int = 0
    public func start() { startedCount += 1 }
    
    public required init(parent: Coordinating?, navigationRouter: NavigationRoutingProtocol, inject: CoreInjectionProtocol) {
        self.parentCoordinator = parent
        self.navigationRouter = navigationRouter
        self.injected = inject
    }
}

public class MockOnboardingCoordinator : OnboardingCoordinatorProtocol {
    public var isOnboardingRequired: Bool = true
    
    public var delegate: OnboardingCoordinatorDelegate?
    
    public var onboardingDidFinish: ((OnboardingCoordinatorProtocol, PreferredNextScreen) -> Void)?
    
    public var parentCoordinator: Coordinating?
    public var uuid: UUID = UUID()
    public var childCoordinators = [UUID : Coordinating]()
    
    public var testNotifyOnStartCalled: (() -> Void)?
    
    public init(parent: Coordinating?) {
        parentCoordinator = parent
    }
    
    public private (set) var startedCount: Int = 0 {
        didSet {
            print("Started count \(startedCount)")
        }
    }
    public func start() {
        startedCount += 1
        testNotifyOnStartCalled?()
    }
    
    /// Call this method to simulate the affect of the onboarding coordinator finishing its last user interaction
    public func completeOnboarding() {
        onboardingDidFinish?(self, .noOpinion)
    }
}

public class MockCoordindator: Coordinating {
    
    public var startCount: Int = 0
    
    public var parentCoordinator: Coordinating?
    
    public var uuid = UUID()
    
    public var childCoordinators: [UUID : Coordinating] = [:]
    
    public func start() {
        startCount += 1
    }
}
