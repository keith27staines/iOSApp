import WorkfinderCommon
import WorkfinderServices

protocol OfferServiceProtocol: AnyObject {
    func fetchOffer(application: Application, completion: @escaping (Result<Offer,Error>) -> Void)
    func accept(offer: Offer, completion: @escaping (Result<Offer, Error>) -> Void)
    func decline(offer: Offer, completion: @escaping (Result<Offer, Error>) -> Void)
}

class OfferService: OfferServiceProtocol{
    
    private let fetchOfferService: FetchOfferService
    private let acceptOfferService: AcceptOfferService
    private let declineOfferService: DeclineOfferService
    
    init(networkConfig: NetworkConfig) {
        fetchOfferService = FetchOfferService(networkConfig: networkConfig)
        acceptOfferService = AcceptOfferService(networkConfig: networkConfig)
        declineOfferService = DeclineOfferService(networkConfig: networkConfig)
    }
    
    func fetchOffer(application: Application, completion: @escaping (Result<Offer,Error>) -> Void) {
        fetchOfferService.fetchOffer(
        uuid: application.placementUuid) { [weak self] (networkResult) in
            guard let self = self else { return }
            switch networkResult {
            case .success(let json):
                let state = ApplicationState(string: json.status)
                let offerState = OfferState(applicationState: state)
                let offer = Offer(
                    placementUuid: application.placementUuid,
                    offerState: offerState,
                    startingDateString: json.start_date,
                    duration: json.offered_duration,
                    hostCompany: json.association?.location?.company?.name,
                    hostContact: json.association?.host?.displayName,
                    email: json.association?.host?.displayName,
                    location: self.addressStringFromOfferJson(json),
                    logoUrl: json.association?.location?.company?.logoUrlString,
                    declineReason: nil)
                completion(Result<Offer,Error>.success(offer))
            case .failure(let error):
                completion(Result<Offer,Error>.failure(error))
            }
        }
    }
    
    func addressStringFromOfferJson(_ json: ExpandedAssociationPlacementJson) -> String {
        let loc = json.association?.location
        return "\(loc?.address_unit ?? ""), \(loc?.address_building ?? ""), \(loc?.address_street ?? ""), \(loc?.address_city ?? ""), \(loc?.address_region ?? ""), \(loc?.address_country?.name ?? ""), \(loc?.address_postcode ?? "")"
    }
    
    func accept(offer: Offer, completion: @escaping (Result<Offer, Error>) -> Void) {
        acceptOfferService.accept(offer: offer) { (result) in
            switch result {
            case .success(let placement):
                var acceptedOffer = offer
                let applicationState = ApplicationState(string: placement.status)
                acceptedOffer.offerState = OfferState(applicationState: applicationState)
                completion(Result<Offer,Error>.success(acceptedOffer))
            case .failure(let error):
                completion(Result<Offer,Error>.failure(error))
            }
        }
    }
    
    func decline(offer: Offer, completion: @escaping (Result<Offer, Error>) -> Void) {
        declineOfferService.decline(offer: offer) { (result) in
            switch result {
            case .success(let placement):
                var declinedOffer = offer
                let applicationState = ApplicationState(string: placement.status)
                declinedOffer.offerState = OfferState(applicationState: applicationState)
                completion(Result<Offer,Error>.success(declinedOffer))
            case .failure(let error):
                completion(Result<Offer,Error>.failure(error))
            }
        }
    }
}

fileprivate class DeclineOfferService: WorkfinderService {
    func decline(offer: Offer, completion: @escaping (Result<Placement,Error>) -> Void) {
        let relativePath = "placement/\(offer.placementUuid)/"
        let patch = ["status": OfferState.candidateDeclined.serverState]
        do {
            let request = try buildRequest(relativePath: relativePath, verb: .patch, body: patch)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(Result<Placement,Error>.failure(error))
        }
    }
}

fileprivate class AcceptOfferService: WorkfinderService {
    func accept(offer: Offer, completion: @escaping (Result<Placement,Error>) -> Void) {
        let relativePath = "placement/\(offer.placementUuid)/"
        let patch = ["status": OfferState.candidateAccepted.serverState]
        do {
            let request = try buildRequest(relativePath: relativePath, verb: .patch, body: patch)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(Result<Placement,Error>.failure(error))
        }
    }
}

fileprivate class FetchOfferService: WorkfinderService {
    func fetchOffer(
        uuid: F4SUUID,
        completion: @escaping (Result<ExpandedAssociationPlacementJson,Error>) -> Void) {
        do {
            let relativePath = "offers/\(uuid)"
            let queryItems = [URLQueryItem(name: "expand-association", value: "1")]
            let request = try buildRequest(relativePath: relativePath, queryItems: queryItems, verb: .get)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(Result<ExpandedAssociationPlacementJson,Error>.failure(error))
        }
    }
}
