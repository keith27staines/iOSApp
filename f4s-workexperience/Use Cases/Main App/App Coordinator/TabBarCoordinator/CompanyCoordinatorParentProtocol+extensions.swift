
import Foundation
import WorkfinderCommon
import WorkfinderCoordinators
import WorkfinderCompanyDetailsUseCase

extension CoreInjectionNavigationCoordinator: CompanyCoordinatorParentProtocol {
    
    public func show(destination: PreferredDestination) {
        switch destination {
        case .applications:
            showApplications()
        case .home:
            showHome()
        case .none:
            break
        }
    }
    
    public func showApplications() {
        injected.appCoordinator?.showApplications(uuid: nil)
    }
    
    public func showHome() {
        injected.appCoordinator?.showSearch()
    }
}
