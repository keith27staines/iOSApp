
import Foundation
import WorkfinderCommon
import WorkfinderCoordinators
import WorkfinderCompanyDetailsUseCase

extension CoreInjectionNavigationCoordinator: CompanyCoordinatorParentProtocol {
    public func switchToTab(_ tab: TabIndex) {
        injected.appCoordinator?.switchToTab(.home)
    }
}
