import WorkfinderCommon

public protocol CompanyCoordinatorProtocol : CoreInjectionNavigationCoordinatorProtocol {}

public protocol CompanyCoordinatorFactoryProtocol {
    func makeCompanyCoordinator(
        parent: CoreInjectionNavigationCoordinator,
        navigationRouter: NavigationRoutingProtocol,
        inject: CoreInjectionProtocol,
        companyUuid: F4SUUID) ->  CompanyCoordinatorProtocol?
    
    func makeCompanyCoordinator(
        parent: CoreInjectionNavigationCoordinator?,
        navigationRouter: NavigationRoutingProtocol,
        company: Company,
        inject: CoreInjectionProtocol) -> CompanyCoordinatorProtocol
}
