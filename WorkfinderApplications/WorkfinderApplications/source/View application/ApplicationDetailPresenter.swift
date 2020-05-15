import WorkfinderCommon
import WorkfinderUI

typealias ApplicationDetail = Application

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
    func load(completion: @escaping (Error?) -> Void)
    func numberOfSections() -> Int
    func numberOfRowsInSection(_ section: Int) -> Int
    func cellInfoForIndexPath(_ indexPath: IndexPath) -> ApplicationDetailCellInfo
}

struct ApplicationDetailCellInfo {
    var heading: String?
    var subheading: String?
}

class ApplicationDetailPresenter: ApplicationDetailPresenterProtocol{
    weak var view: WorkfinderViewControllerProtocol?
    
    func numberOfSections() -> Int { 1 }
    func numberOfRowsInSection(_ section: Int) -> Int { 3 }
    func cellInfoForIndexPath(_ indexPath: IndexPath) -> ApplicationDetailCellInfo {
        switch indexPath.row {
        case 0:
            return ApplicationDetailCellInfo(heading: self.companyName, subheading: self.companyCaption)
        case 1:
            return ApplicationDetailCellInfo(heading: self.hostName, subheading: self.hostCaption)
        case 2:
            return ApplicationDetailCellInfo(heading: "Documents", subheading: "0 files")
        default: return ApplicationDetailCellInfo()
        }
    }
    
    var companyCaption: String? { applicationDetail?.industry}
    var hostName: String? { applicationDetail?.hostName }
    var hostCaption: String? { applicationDetail?.hostRole }
    var coverLetterText: String? { applicationDetail?.coverLetterString }
    var companyName: String? { applicationDetail?.companyName }
    
    let service: ApplicationDetailServiceProtocol
    let coordinator: ApplicationsCoordinatorProtocol
    let application: Application
    var applicationDetail: ApplicationDetail?
    
    var screenTitle: String { application.state.screenTitle }
    var stateDescription: String { application.state.description }
    var logoUrl: String? { application.logoUrl }
    
    init(coordinator: ApplicationsCoordinatorProtocol,
         service: ApplicationDetailService,
         application: Application) {
        self.service = service
        self.coordinator = coordinator
        self.application = application
    }
    
    func onViewDidLoad(view: WorkfinderViewControllerProtocol) {
        self.view = view
    }
    
    func load(completion: @escaping (Error?) -> Void) {
        service.fetchApplicationDetail(application: application) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let applicationDetail):
                self.applicationDetail = applicationDetail
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
}
