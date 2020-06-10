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
}

class OfferPresenter: OfferPresenterProtocol {
    weak var coordinator: ApplicationsCoordinator?
    weak var view: WorkfinderViewControllerProtocol?
    private let application: Application
    let service: OfferServiceProtocol
    private var offer: Offer?
    var companyName: String { application.companyName }
    var offerState: OfferState? { offer?.offerState }
    var startingDateString: String? { offer?.startingDateString }
    var duration: String? { offer?.duration }
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
    func numberOfRowsInSection(_ section: Int) -> Int { OfferTableRowType.allCases.count }
    func cellInfoForIndexPath(_ indexPath: IndexPath) -> OfferDetailCellInfo {
        let rowType = OfferTableRowType(rawValue: indexPath.row)!
        switch rowType {
        case .startDate:
            return OfferDetailCellInfo(firstLine: "Start date", secondLine: offer?.startingDateString)
        case .endDate:
            return OfferDetailCellInfo(firstLine: "End date", secondLine: offer?.duration)
        case .company:
            return OfferDetailCellInfo(firstLine: "Host company", secondLine: offer?.hostCompany)
        case .host:
            return OfferDetailCellInfo(firstLine: "Host contact", secondLine: offer?.hostContact)
        case .email:
            return OfferDetailCellInfo(firstLine: "Email", secondLine: offer?.email)
        case .location:
            return OfferDetailCellInfo(firstLine: "Location", secondLine: offer?.location)
        case .notes:
            return OfferDetailCellInfo(firstLine: "Notes", secondLine: "Some random notes until the time this functionality is wired into the server. This can expand to many lines of text if necessary. If a million monkeys are given a million typewriters, how likely is it that one of them would write iOS Workfinder app?. Philosophy is pointless, we live in a simulation and everything is controlled by chance and the great coder in the sky. I'm quite hungry, I haven't had breakfast")
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

