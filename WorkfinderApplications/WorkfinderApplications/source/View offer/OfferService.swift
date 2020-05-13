import WorkfinderCommon
import WorkfinderServices

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
