
import Foundation
import WorkfinderCommon
import WorkfinderCoordinators
import WorkfinderCompanyDetailsUseCase

extension CoreInjectionNavigationCoordinator: CompanyCoordinatorParentProtocol {
    public func showMessages() {
        injected.appCoordinator?.showMessages()
    }
    
    public func showSearch() {
        injected.appCoordinator?.showSearch()
    }
}
