
import Foundation
import WorkfinderCommon
import WorkfinderCoordinators
import WorkfinderCompanyDetailsUseCase

extension CoreInjectionNavigationCoordinator: CompanyCoordinatorParentProtocol {
    public func showMessages() {
        TabBarCoordinator.sharedInstance.navigateToTimeline()
    }
    
    public func showSearch() {
        TabBarCoordinator.sharedInstance.navigateToMap()
    }
}
