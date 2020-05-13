import Foundation

class ApplicationsPresenter {
    weak var coordinator: ApplicationsCoordinatorProtocol?
    let numberOfSections: Int = 1
    let service: ApplicationsServiceProtocol
    var applications = [Application]()
    var applicationTilePresenters = [ApplicationTilePresenter]()
    
    init(coordinator: ApplicationsCoordinatorProtocol, service: ApplicationsService) {
        self.service = service
        self.coordinator = coordinator
    }
    
    func numberOfRows(section: Int) -> Int {
        return applicationTilePresenters.count
    }
    
    func applicationTilePresenterForIndexPath(_ indexPath: IndexPath) -> ApplicationTilePresenter {
        return applicationTilePresenters[indexPath.row]
    }
    
    func applicationForIndexPath(_ indexPath: IndexPath) -> Application {
        return applications[indexPath.row]
    }
    
    func onViewDidLoad(completion: @escaping (Error?) -> Void) {
        service.fetchApplications { result in
            self.applicationTilePresenters = []
            switch result {
            case .success(let applications):
                self.applications = applications
                self.coordinator?.applicationsDidLoad(applications)
                self.applicationTilePresenters = applications.map({ (application) -> ApplicationTilePresenter in
                    ApplicationTilePresenter(application: application)
                })
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func onTapApplication(at indexPath: IndexPath) {
        let application = applicationForIndexPath(indexPath)
        let action: ApplicationAction
        switch application.state {
        case .applied: action = .viewApplication
        case .viewedByHost: action = .viewApplication
        case .applicationDeclined: action = .viewApplication
        case .offerMade: action = .viewOffer
        case .offerAccepted: action = .viewOffer
        case .offerDeclined: action = .viewOffer
        }
        coordinator?.performAction(action, for: application)
    }
}
