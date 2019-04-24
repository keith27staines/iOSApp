import Foundation
import WorkfinderCommon

/// RecommendationsCoordinator is responsible for:
/// 1. Instantiate views, view models and models to display a list of recommended companies
/// 2. Oversee the presentation of the view
/// 3. Manage the transition into the apply workflow should the user decide to apply to a recommendation
class RecommendationsCoordinator : CoreInjectionNavigationCoordinator, ApplyCoordinatorCoordinating {
    
    /// When the first part of the apply workflow (create placement) finishes, the apply use-case module
    /// hands back responsibility for the remaining jobs (capture user details, verify email, etc)
    func continueApplicationFromPlacementInAppliedState(_ placementJson: WEXPlacementJson, takingOverFrom coordinator: Coordinating) {
        let user = F4SUser()
        let company = self.company!
        let availabilityPeriod = F4SAvailabilityPeriod(availabilityPeriodJson: placementJson.availabilityPeriods!.first!)
        let placement = F4SPlacement(
            userUuid: user.uuid,
            companyUuid: company.uuid,
            interestList: [],
            status: placementJson.workflowState,
            placementUuid: placementJson.uuid!)
        let applicationContext = F4SApplicationContext(
            user: user,
            company: company,
            placement: placement,
            availabilityPeriod: availabilityPeriod)
        TabBarCoordinator.sharedInstance.pushProcessedMessages(navigationRouter.navigationController, applicationContext: applicationContext)
    }
    
    lazy var model: RecommendedCompaniesListModelProtocol = {
        return RecommendedCompaniesListModel()
    }()
    
    lazy var viewModel: RecommendationsViewModel = {
        return RecommendationsViewModel(coordinator: self, model: model, view: rootViewController)
    }()
    
    lazy var rootViewController: RecommendationsListViewController = {
        let storyboard = UIStoryboard(name: "Recommendations", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "RecommendationsViewController") as! RecommendationsListViewController
        return controller
    }()
    
    override func start() {
        rootViewController.inject(viewModel: viewModel)
        navigationRouter.navigationController.pushViewController(rootViewController, animated: false)
    }
    
    var company: Company?
    
    func showDetail(companyUuid: F4SUUID) {
        company = companyFromUuid(companyUuid)
        guard let company = company else { return }
        let companyCoordinator = CompanyCoordinator(parent: self, navigationRouter: navigationRouter, company: company, inject: injected)
        addChildCoordinator(companyCoordinator)
        companyCoordinator.start()
    }
    
    func companyFromUuid(_ companyUuid: F4SUUID) -> Company? {
        return DatabaseOperations.sharedInstance.companyWithUUID(companyUuid)
    }
    
}


