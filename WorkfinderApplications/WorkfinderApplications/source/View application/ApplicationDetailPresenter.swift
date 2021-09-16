
import WorkfinderCommon
import WorkfinderUI

protocol ApplicationDetailPresenterProtocol {
    var screenTitle: String { get }
    var logoUrl: String? { get }
    var stateDescription: String { get }
    var coverLetterText: String? { get }
    var companyName: String? { get }
    var companyCaption: String? { get }
    var hostName: String? { get }
    var hostCaption: String? { get }
    func onViewDidLoad(view: WorkfinderViewControllerProtocol)
    func loadData(completion: @escaping (Error?) -> Void)
    func numberOfSections() -> Int
    func numberOfRowsInSection(_ section: Int) -> Int
    func cellInfoForIndexPath(_ indexPath: IndexPath) -> ApplicationDetailCellInfo
    func showDisclosureIndicatorForIndexPath(_ indexPath: IndexPath) -> Bool
    func onTapDetail(indexPath: IndexPath)
}

struct ApplicationDetailCellInfo {
    var heading: String?
    var subheading: String?
}

class ApplicationDetailPresenter: ApplicationDetailPresenterProtocol {
    weak var view: WorkfinderViewControllerProtocol?
    
    func numberOfSections() -> Int { 1 }
    func numberOfRowsInSection(_ section: Int) -> Int { 2 }
    func cellInfoForIndexPath(_ indexPath: IndexPath) -> ApplicationDetailCellInfo {
        switch indexPath.row {
        case 0:
            return ApplicationDetailCellInfo(heading: self.companyName, subheading: self.companyCaption)
        case 1:
            return ApplicationDetailCellInfo(heading: self.hostName, subheading: self.hostCaption)
        default: return ApplicationDetailCellInfo()
        }
    }
    
    var companyCaption: String? { application?.industry}
    var hostName: String? { application?.hostName }
    var hostCaption: String? { application?.hostRole }
    var coverLetterText: String? { application?.coverLetterString }
    var companyName: String? { application?.companyName }
    
    let placementUuid: F4SUUID
    let applicationService: PlacementDetailServiceProtocol
    let coordinator: ApplicationsCoordinatorProtocol
    var application: Application?
    
    var screenTitle: String { application?.state.screenTitle ?? "" }
    var stateDescription: String { application?.state.description ?? "" }
    var logoUrl: String? { application?.state.description ?? "" }
    
    init(coordinator: ApplicationsCoordinatorProtocol,
         applicationService: ApplicationDetailService,
         placementUuid: F4SUUID
    ) {
        self.applicationService = applicationService
        self.coordinator = coordinator
        self.placementUuid = placementUuid
    }
    
    func onViewDidLoad(view: WorkfinderViewControllerProtocol) {
        self.view = view
    }
    
    func loadData(completion: @escaping (Error?) -> Void) {
        applicationService.fetchApplication(placementUuid: placementUuid) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let applicationDetail):
                self.application = applicationDetail
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func onTapDetail(indexPath: IndexPath) {
        guard let applicationDetail = application else { return }
        switch indexPath.row {
        case 0: coordinator.showCompany(application: applicationDetail)
        case 1: coordinator.showCompanyHost(application: applicationDetail)
        default: break
        }
    }
    
    func showDisclosureIndicatorForIndexPath(_ indexPath: IndexPath) -> Bool {
        return true
    }
}
