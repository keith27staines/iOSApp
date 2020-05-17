import WorkfinderUI

protocol OfferPresenterProtocol {
    var hideAcceptDeclineButtons: Bool { get }
    var screenTitle: String { get }
    var stateDescription: String? { get }
    var logoUrl: String? { get }
    func onViewDidLoad(view: WorkfinderViewControllerProtocol)
    func onTapAccept(completion: @escaping (Error?) -> Void)
    func onTapDeclineWithReason(_ declineReason: DeclineReason, completion: @escaping (Error?) -> Void)
    func loadData(completion: @escaping (Error?) -> Void)
    func numberOfSections() -> Int
    func numberOfRowsInSection(_ section: Int) -> Int
    func cellInfoForIndexPath(_ indexPath: IndexPath) -> OfferDetailCellInfo
}

class OfferPresenter: OfferPresenterProtocol {
    weak var coordinator: ApplicationsCoordinator?
    weak var view: WorkfinderViewControllerProtocol?
    private let application: Application
    let service: OfferServiceProtocol
    private var offer: Offer?
    
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
        guard let state = offerState, state == .open else { return true }
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
    
    func onTapDeclineWithReason(_ reason: DeclineReason, completion: @escaping (Error?) -> Void) {
        guard var offer = offer else { return }
        offer.declineReason = reason
        service.decline(offer: offer) { [weak self] (result) in
            offer.declineReason = reason
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
    func numberOfRowsInSection(_ section: Int) -> Int { 6 }
    func cellInfoForIndexPath(_ indexPath: IndexPath) -> OfferDetailCellInfo {
        switch indexPath.row {
        case 0:
            return OfferDetailCellInfo(firstLine: "Starting date", secondLine: offer?.startingDateString)
        case 1:
            return OfferDetailCellInfo(firstLine: "Duration", secondLine: offer?.duration)
        case 2:
            return OfferDetailCellInfo(firstLine: "Host company", secondLine: offer?.hostCompany)
        case 3:
            return OfferDetailCellInfo(firstLine: "Host contact", secondLine: offer?.hostContact)
        case 4:
            return OfferDetailCellInfo(firstLine: "Email", secondLine: offer?.email)
        case 5:
            return OfferDetailCellInfo(firstLine: "Location", secondLine: offer?.location)
        default: return OfferDetailCellInfo(firstLine: nil, secondLine: nil)
        }
    }
}


