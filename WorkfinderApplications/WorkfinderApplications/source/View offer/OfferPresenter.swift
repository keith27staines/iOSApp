import WorkfinderUI

protocol OfferPresenterProtocol {
    var companyName: String { get }
    var hideAcceptDeclineButtons: Bool { get }
    var screenTitle: String { get }
    var stateDescription: String? { get }
    var logoUrl: String? { get }
    func onViewDidLoad(view: WorkfinderViewControllerProtocol)
    func loadData(completion: @escaping (Error?) -> Void)
    func numberOfSections() -> Int
    func numberOfRowsInSection(_ section: Int) -> Int
    func cellInfoForIndexPath(_ indexPath: IndexPath) -> OfferDetailCellInfo
    func onTapAccept(completion: @escaping (Error?) -> Void)
    func onTapDeclineWithReason(_ declineReason: WithdrawReason,
                                otherText: String?,
                                completion: @escaping (Error?) -> Void)
    func didSelectRowAtIndexPath(_ indexPath: IndexPath)
    func accessoryTypeForIndexPath(_ indexPath: IndexPath) -> UITableViewCell.AccessoryType
    func isNotesField(_ indexPath: IndexPath) -> Bool
}

class OfferPresenter: OfferPresenterProtocol {
    weak var coordinator: ApplicationsCoordinator?
    weak var view: WorkfinderViewControllerProtocol?
    private let application: Application
    let service: OfferServiceProtocol
    private var offer: Offer?
    var companyName: String { application.companyName }
    var offerState: OfferState? { offer?.offerState }
    var startDateString: String? { offer?.startDateString }
    var endDateString: String? { offer?.endDateString }
    var hostCompany: String? { offer?.hostCompany }
    var hostContact: String? { offer?.hostContact }
    var email: String? { offer?.email }
    var location: String? { offer?.location }
    var screenTitle: String { offerState?.screenTitle ?? "Offer"}
    var stateDescription: String? { return offerState?.description }
    var logoUrl: String? { offer?.logoUrl}
    var hideAcceptDeclineButtons: Bool {
        guard let state = offerState, state == .hostOfferOpen else { return true }
        return false
    }
    
    init(coordinator: ApplicationsCoordinator,
         application: Application,
         service: OfferServiceProtocol) {
        self.coordinator = coordinator
        self.application = application
        self.service = service
    }
    
    func isNotesField(_ indexPath: IndexPath) -> Bool {
        let rowType = OfferTableRowType(rawValue: indexPath.row)
        return rowType == OfferTableRowType.notes
    }
    
    func onViewDidLoad(view: WorkfinderViewControllerProtocol) {
        self.view = view
    }
    
    func loadData(completion: @escaping (Error?) -> Void) {
        service.fetchOffer(application: application) {  [weak self] (result) in
            self?.resultHandler(result: result, completion: completion)
        }
    }
    
    func onTapAccept(completion: @escaping (Error?) -> Void) {
        guard let offer = offer else { return }
        service.accept(offer: offer) {  [weak self] (result) in
            self?.resultHandler(result: result, completion: completion)
        }
    }
    
    func onTapDeclineWithReason(_ reason: WithdrawReason, otherText: String?, completion: @escaping (Error?) -> Void) {
        guard var offer = offer else { return }
        service.withdraw(declining: offer, reason: reason, otherText: otherText) { [weak self] (result) in
            offer.reasonWithdrawn = reason
            self?.resultHandler(result: result, completion: completion)
        }
    }
    
    func resultHandler(result: Result<Offer,Error>, completion: @escaping (Error?) -> Void) {
        switch result {
        case .success(let offer):
            self.offer = offer
            completion(nil)
        case .failure(let error):
            completion(.some(error))
        }
    }
    
    func numberOfSections() -> Int { 1 }
    func numberOfRowsInSection(_ section: Int) -> Int {
        guard section == 0 else { return 0 }
        return OfferTableRowType.allCases.count
    }
    func cellInfoForIndexPath(_ indexPath: IndexPath) -> OfferDetailCellInfo {
        
        let rowType = OfferTableRowType(rawValue: indexPath.row)!
        switch rowType {
        case .startDate:
            return OfferDetailCellInfo(firstLine: "Start date", secondLine: offer?.startDateString)
        case .endDate:
            return OfferDetailCellInfo(firstLine: "End date", secondLine: offer?.endDateString)
        case .company:
            return OfferDetailCellInfo(firstLine: "Host company", secondLine: offer?.hostCompany)
        case .host:
            return OfferDetailCellInfo(firstLine: "Host contact", secondLine: offer?.hostContact)
        case .email:
            return OfferDetailCellInfo(firstLine: "Email", secondLine: offer?.email)
        case .location:
            return OfferDetailCellInfo(firstLine: "Location", secondLine: offer?.location)
        case .notes:
            return OfferDetailCellInfo(firstLine: "Notes", secondLine: offer?.offerNotes)
        }
    }
    
    func didSelectRowAtIndexPath(_ indexPath: IndexPath) {
        let rowType = OfferTableRowType(rawValue: indexPath.row)!
        switch rowType {
        case .startDate: break
        case .endDate: break
        case .company: coordinator?.showCompany(application: application)
        case .host: coordinator?.showCompanyHost(application: application)
        case .email: break
        case .location: break
        case .notes: break
        }
    }
    
    func accessoryTypeForIndexPath(_ indexPath: IndexPath) -> UITableViewCell.AccessoryType {
        guard let rowType = OfferTableRowType(rawValue: indexPath.row) else { return .none }
        switch rowType {
        case .startDate: return .none
        case .endDate: return .none
        case .company: return .disclosureIndicator
        case .host: return .disclosureIndicator
        case .email: return .none
        case .location: return .none
        case .notes: return .none
        }
    }
}

fileprivate enum OfferTableRowType: Int, CaseIterable {
    case startDate
    case endDate
    case company
    case host
    case email
    case location
    case notes
}

