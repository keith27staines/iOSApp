
import Foundation
import WorkfinderCommon
import WorkfinderCoordinators
import WorkfinderCompanyDetailsUseCase

extension CoreInjectionNavigationCoordinator: CompanyCoordinatorParentProtocol {
    
    public func show(destination: PreferredDestination) {
        switch destination {
        case .applications:
            showApplications()
        case .messages:
            showMessages()
        case .search:
            showSearch()
        case .none:
            break
        }
    }
    public func showMessages() {
        //injected.appCoordinator?.showMessages()
    }
    
    public func showApplications() {
        injected.appCoordinator?.showApplications()
    }
    
    public func showSearch() {
        injected.appCoordinator?.showSearch()
    }
}
