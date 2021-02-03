import Foundation
import WorkfinderUI
import WorkfinderCommon

class ApplicationsPresenter {
    weak var coordinator: ApplicationsCoordinatorProtocol?
    let numberOfSections: Int = 1
    let service: ApplicationsServiceProtocol
    var applications: [Application] { pager.items }
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
        return pager.items.count
    }
    
    func applicationTilePresenterForIndexPath(_ indexPath: IndexPath) -> ApplicationTilePresenter {
        let application = applicationForIndexPath(indexPath)
        return ApplicationTilePresenter(application: application)
    }
    
    func applicationForIndexPath(_ indexPath: IndexPath) -> Application {
        return applications[indexPath.row]
    }
    
    func onViewDidLoad(view: WorkfinderViewControllerProtocol) {
        self.view = view
    }
    
    func loadData(table: UITableView, completion: @escaping (Error?) -> Void) {
        guard isCandidateSignedIn() else {
            completion(nil)
            return
        }
        pager.isLoading = true
        service.fetchApplications { [weak self] result in
            guard let self = self else { return }
            self.pager.update(table: table, with: result) { error in
                completion(error)
            }
        }
    }
    
    func loadNextPage(tableView: UITableView) {
        guard let nextPage = pager.nextPage else { return }
        pager.isLoading = true
        service.fetchNextPage(urlString: nextPage) { [weak self] (result) in
            guard let self = self else { return }
            self.pager.update(table: tableView, with: result)
        }
    }
    
    var pager = ServerListPager<Application>()
    
    func onTapApplication(at indexPath: IndexPath) {
        let application = applicationForIndexPath(indexPath)
        let action: ApplicationAction
        switch application.state {
        case .applied: action = .viewApplication
        case .pending: action = .viewApplication
        case .contacting: action = .viewApplication
        case .viewed: action = .viewApplication
        case .saved: action = .viewApplication
        case .declined: action = .viewApplication
        case .offered: action = .viewOffer
        case .accepted: action = .viewOffer
        case .withdrawn: action = .viewOffer
        case .expired: action = .viewApplication
        case .cancelled: action = .viewOffer
        case .unknown: action = .viewApplication
        }
        coordinator?.performAction(action, for: application, appSource: .applicationsTab)
    }
}
