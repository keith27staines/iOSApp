
import Foundation

public protocol AssociationsServiceProtocol {
    func fetchAssociation(uuid: F4SUUID, completion:  @escaping((Result<AssociationJson,Error>) -> Void))
    func fetchAssociations(for locationUuid: F4SUUID, completion:  @escaping((Result<HostAssociationListJson,Error>) -> Void))
}

public struct ServerListJson<A:Decodable>: Decodable {
    public var count: Int?
    public var next: String?
    public var previous: String?
    public var results: [A]
}

public struct AssociationJson: Codable, Equatable, Hashable {
    public var uuid: F4SUUID
    public var location: F4SUUID
    public var host: Host // F4SUUID
    public var title: String? = nil
    public var description: String? = nil
    public var started: String? = nil
    public var stopped: String? = nil
    public var isSelected: Bool = false
    
//    public init(uuid: F4SUUID,locationUuid: F4SUUID, hostUuid: F4SUUID) {
//        self.uuid = uuid
//        self.locationUuid = locationUuid
//        self.host = hostUuid
//    }
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case location
        case host
        case title
        case description
        case started
        case stopped
    }
}

/// Like an AssociationJson but with a full host object rather than a uuid
public struct HostAssociationJson: Codable, Equatable, Hashable {
    public var uuid: F4SUUID
    public var location: CompanyLocationJson
    public var host: Host
    public var title: String?
    public var description: String?
    public var started: String?
    public var stopped: String?
    public var isSelected: Bool = false
    
//    public init(uuidAssociation: AssociationJson, host:Host) {
//        self.uuid = uuidAssociation.uuid
//        self.location = uuidAssociation.location
//        self.host = host
//        self.title = uuidAssociation.title
//        self.description = uuidAssociation.description
//        self.started = uuidAssociation.started
//        self.stopped = uuidAssociation.stopped
//        self.isSelected = uuidAssociation.isSelected
//    }
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case location
        case host
        case title
        case description
        case started
        case stopped
    }
}

public protocol TemplateProviderProtocol: class {
    func fetchCoverLetterTemplateListJson(completion: @escaping ((Result<[TemplateModel],Error>) -> Void))
}

public protocol PicklistProviderProtocol: class {
    var picklistType: PicklistType { get }
    var filters: [URLQueryItem] { get set }
    func fetchPicklistItems(completion: @escaping ((Result<PicklistServerJson,Error>) -> Void))
}

public protocol WorkplaceListProviderProtocol: class {
    func fetchWorkplaces(
        locationUuids: [F4SUUID],
        completion: @escaping ((Result<CompanyListJson,Error>) -> Void))
}

public protocol HostsProviderProtocol: class {
    func fetchHost(uuid: String, completion: @escaping (Result<Host,Error>) -> Void)
    func fetchHosts(locationUuid: F4SUUID, completion: @escaping((Result<HostListJson,Error>) -> Void) )
}
