
import Foundation

public protocol AssociationsServiceProtocol {
    func fetchAssociation(uuid: F4SUUID, completion:  @escaping((Result<AssociationJson,Error>) -> Void))
    func fetchAssociations(queryItems: [URLQueryItem], completion:  @escaping((Result<HostAssociationListJson,Error>) -> Void))
    func fetchAssociations(for locationUuid: F4SUUID, completion:  @escaping((Result<HostAssociationListJson,Error>) -> Void))
    func fetchAssociationsWithUrl(_ urlString: String, completion:  @escaping((Result<HostAssociationListJson,Error>) -> Void))
}

public struct ServerListJson<A:Decodable>: Decodable {
    public var count: Int?
    public var next: String?
    public var previous: String?
    public var results: [A]
    public init(count: Int?, next: String?, previous: String?, results: [A]) {
        self.count = count
        self.next = next
        self.previous = previous
        self.results = results
    }
}

public protocol TemplateProviderProtocol: AnyObject {
    func fetchCoverLetterTemplateListJson(completion: @escaping ((Result<[TemplateModel],Error>) -> Void))
}

public protocol PicklistProviderProtocol: AnyObject {
    var picklistType: PicklistType { get }
    var filters: [URLQueryItem] { get set }
    func fetchPicklistItems(completion: @escaping ((Result<PicklistServerJson,Error>) -> Void))
}

public protocol HostsProviderProtocol: AnyObject {
    func fetchHost(uuid: String, completion: @escaping (Result<HostJson,Error>) -> Void)
    func fetchHosts(locationUuid: F4SUUID, completion: @escaping((Result<HostListJson,Error>) -> Void) )
}
