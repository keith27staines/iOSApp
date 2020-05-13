

protocol OfferServiceProtocol: AnyObject {
    func fetchOffer(application: Application, completion: @escaping (Result<Offer,Error>) -> Void)
    func accept(offer: Offer, completion: @escaping (Result<Offer, Error>) -> Void)
    func decline(offer: Offer, completion: @escaping (Result<Offer, Error>) -> Void)
}

class OfferService: OfferServiceProtocol{
    
    func fetchOffer(application: Application, completion: @escaping (Result<Offer,Error>) -> Void) {
        let offerState = OfferState(applicationState: application.state)
        let offer = Offer(offerState: offerState, startingDateString: "14-Jun-2020", duration: "15 days", hostCompany: application.companyName, hostContact: application.hostName, email: "someemail@somewhere.com", location: "Fabulous location, Wonder Street, Heavenly City")
        completion(Result<Offer,Error>.success(offer))
        
    }
    
    func accept(offer: Offer, completion: @escaping (Result<Offer, Error>) -> Void) {
        var updatedOffer = offer
        updatedOffer.offerState = .accepted
        completion(Result<Offer,Error>.success(updatedOffer))
    }
    
    func decline(offer: Offer, completion: @escaping (Result<Offer, Error>) -> Void) {
        var updatedOffer = offer
        updatedOffer.offerState = .declined
        completion(Result<Offer,Error>.success(updatedOffer))
    }
    
}

enum OfferState {
    case open
    case accepted
    case declined
    case unknown
    
    init(applicationState: ApplicationState) {
        switch applicationState {
        case .offerMade: self = .open
        case .offerAccepted: self = .accepted
        case .offerDeclined: self = .declined
        default: self = .unknown
        }
    }
}

struct Offer {
    var offerState: OfferState?
    var startingDateString: String?
    var duration: String?
    var hostCompany: String?
    var hostContact: String?
    var email: String?
    var location: String?
}

protocol OfferPresenterProtocol {
    func load(application: Application, completion: @escaping (Error?) -> Void)
}

class OfferPresenter: OfferPresenterProtocol {
    weak var coordinator: ApplicationsCoordinator?
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
    
    init(coordinator: ApplicationsCoordinator,
         application: Application,
         service: OfferServiceProtocol) {
        self.coordinator = coordinator
        self.application = application
        self.service = service
    }
    
    func load(application: Application, completion: @escaping (Error?) -> Void) {
        service.fetchOffer(application: application) {  [weak self] (result) in
            self?.resultHandler(result: result, completion: completion)
        }
    }
    
    func accept(offer: Offer, completion: @escaping (Error?) -> Void) {
        service.accept(offer: offer) {  [weak self] (result) in
            self?.resultHandler(result: result, completion: completion)
        }
    }
    
    func decline(offer: Offer, completion: @escaping (Error?) -> Void) {
        service.decline(offer: offer) { [weak self] (result) in
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
}
