import WorkfinderCommon
import WorkfinderServices

protocol OfferServiceProtocol: AnyObject {
    func fetchOffer(application: Application, completion: @escaping (Result<Offer,Error>) -> Void)
    func accept(offer: Offer, completion: @escaping (Result<Offer, Error>) -> Void)
    func withdraw(declining offer: Offer, reason: WithdrawReason, otherText: String?, completion: @escaping (Result<Offer, Error>) -> Void)
}

class OfferService: OfferServiceProtocol{
    
    private let fetchOfferService: FetchOfferService
    private let acceptOfferService: AcceptOfferService
    private let withdrawService: WithdrawService
    
    init(networkConfig: NetworkConfig) {
        fetchOfferService = FetchOfferService(networkConfig: networkConfig)
        acceptOfferService = AcceptOfferService(networkConfig: networkConfig)
        withdrawService = WithdrawService(networkConfig: networkConfig)
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
                    startDateString: json.start_date,
                    endDateString: json.end_date,
                    hostCompany: json.association?.location?.company?.name,
                    hostContact: json.association?.host?.displayName,
                    email: json.association?.host?.emails?.first,
                    location: self.addressStringFromOfferJson(json),
                    logoUrl: json.association?.location?.company?.logo,
                    reasonWithdrawn: nil,
                    offerNotes: json.offer_notes)
                completion(Result<Offer,Error>.success(offer))
            case .failure(let error):
                completion(Result<Offer,Error>.failure(error))
            }
        }
    }
    
    func addressStringFromOfferJson(_ json: ExpandedAssociationPlacementJson) -> String {
        let loc = json.association?.location
        var addressElements = [String]()
        if let element = loc?.address_unit { addressElements.append(element) }
        if let element = loc?.address_building { addressElements.append(element) }
        if let element = loc?.address_street { addressElements.append(element) }
        if let element = loc?.address_city { addressElements.append(element) }
        if let element = loc?.address_region { addressElements.append(element) }
        if let element = loc?.address_country?.name { addressElements.append(element) }
        if let element = loc?.address_postcode { addressElements.append(element) }
        var commaList = addressElements.reduce("") { (result, element) -> String in
            element.isEmpty ? result : result + ", \(element)"
        }
        if commaList.prefix(2) == ", " { commaList = String(commaList.dropFirst(2))}
        return String(commaList)
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
    
    func withdraw(declining offer: Offer,
                  reason: WithdrawReason,
                  otherText: String?,
                  completion: @escaping (Result<Offer, Error>) -> Void) {
        withdrawService.withdraw(declining: offer,
                                 reason: reason,
                                 otherReason: otherText) { (result) in
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

fileprivate class WithdrawService: WorkfinderService {
    func withdraw(declining offer: Offer,
                 reason: WithdrawReason,
                 otherReason: String?,
                 completion: @escaping (Result<Placement,Error>) -> Void) {
        let relativePath = "placements/\(offer.placementUuid)/"
        var patch: [String: String] = ["status": OfferState.candidateWithdrew.serverState]
        if let otherReason = otherReason {
            patch["reason_withdrawn_other"] = otherReason
        } else {
            patch["reason_withdrawn"] = reason.buttonTitle
        }
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
        let relativePath = "placements/\(offer.placementUuid)/"
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
