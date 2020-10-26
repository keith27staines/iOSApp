import Foundation
import WorkfinderUI

class ApplicationsPresenter {
    weak var coordinator: ApplicationsCoordinatorProtocol?
    let numberOfSections: Int = 1
    let service: ApplicationsServiceProtocol
    var applications = [Application]()
    var applicationTilePresenters = [ApplicationTilePresenter]()
    weak var view: WorkfinderViewControllerProtocol?
    var isCandidateSignedIn: () -> Bool
    
    init(coordinator: ApplicationsCoordinatorProtocol,
         service: ApplicationsService,
         isCandidateSignedIn: @escaping () -> Bool) {
        self.service = service
        self.coordinator = coordinator
        self.isCandidateSignedIn = isCandidateSignedIn
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
    
    func onViewDidLoad(view: WorkfinderViewControllerProtocol) {
        self.view = view
    }
    
    func loadData(completion: @escaping (Error?) -> Void) {
        guard isCandidateSignedIn() else {
            completion(nil)
            return
        }
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
        case .contactingHost: action = .viewApplication
        case .viewedByHost: action = .viewApplication
        case .savedByHost: action = .viewApplication
        case .applicationDeclined: action = .viewApplication
        case .offerMade: action = .viewOffer
        case .offerAccepted: action = .viewOffer
        case .candidateWithdrew: action = .viewOffer
        case .expired: action = .viewApplication
        case .cancelled: action = .viewOffer
        case .unknown: action = .viewApplication
        }
        coordinator?.performAction(action, for: application)
    }
}
