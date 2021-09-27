
import WorkfinderCommon
import WorkfinderUI

struct ApplicationDetailCellInfo {
    var heading: String?
    var subheading: String?
}

class ApplicationDetailPresenter {
    
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
    var projectName: String? { application?.projectName }
    var hostCaption: String? { application?.hostRole }
    var coverLetterText: String? { application?.coverLetterString }
    var companyName: String? { application?.companyName }
    var headerData: ApplicationDetailHeaderData? {
        ApplicationDetailHeaderData(application: application)
    }
    
    let placementUuid: F4SUUID
    let applicationService: PlacementDetailServiceProtocol
    let coordinator: ApplicationsCoordinatorProtocol
    var application: Application?
    
    var screenTitle: String { application?.state.screenTitle ?? "" }
    var stateDescription: String { application?.state.description ?? "" }
    var logoUrl: String? { application?.state.description ?? "" }

    var interviewInviteTileIsHidden: Bool {
        interviewInviteData == nil
    }
    
    var interviewOfferTileIsHidden: Bool {
        interviewOfferData == nil
    }
    
    var statusLabelIsHidden: Bool {
        !(interviewInviteTileIsHidden && interviewOfferTileIsHidden)
    }
    
    var interviewInviteData: InterviewInviteTileData? {
        guard
            let interview = application?.interviewJson,
            interview.status == "interview_accepted" ||
            interview.status == "meeting_link_added"
        else { return nil }
        return InterviewInviteTileData(interview: interview)
    }
    
    var interviewOfferData: OfferTileData? {
        guard
            let interview = application?.interviewJson, interview.status == "interview_offered"
        else { return nil }
        return OfferTileData(interview: interview) { [weak self] offerTileData in
            guard let self = self else { return }
            self.coordinator.performAction(.viewInterview(interviewId: interview.id ?? -1), appSource: .applicationsTab)
            print("offer tile tapped")
        }
    }
    
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
            case .success(let application):
                self.application = application
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
