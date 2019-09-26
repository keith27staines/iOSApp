
public protocol F4SPartnersModelProtocol {
    //static func hardCodedPartners() -> [F4SPartner]
    var selectedPartner: F4SPartner? { get set }
    func getPartnersFromServer(completed: ((F4SNetworkResult<[F4SPartner]>) -> Void)?)
    func numberOfSections() -> Int
    func numberOfRowsInSection(_ section: Int) -> Int
    func partnerForIndexPath(_ indexPath: IndexPath) -> F4SPartner
}
