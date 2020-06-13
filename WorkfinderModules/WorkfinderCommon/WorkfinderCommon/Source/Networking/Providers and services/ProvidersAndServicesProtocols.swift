
import Foundation

public protocol AssociationsServiceProtocol {
    func fetchAssociation(uuid: F4SUUID, completion:  @escaping((Result<AssociationJson,Error>) -> Void))
    func fetchAssociations(for locationUuid: F4SUUID, completion:  @escaping((Result<HostAssociationListJson,Error>) -> Void))
}

public struct ServerListJson<A:Decodable>: Decodable {
    public var count: Int?
    public var next: String?
    public var previous: String?
    public let results: [A]
}

public struct AssociationJson: Codable {
    public let uuid: F4SUUID
    public let locationUuid: F4SUUID
    public let host: F4SUUID
    public let title: String? = nil
    public let description: String? = nil
    public let started: String? = nil
    public let stopped: String? = nil
    public var isSelected: Bool = false
    
    public init(uuid: F4SUUID,locationUuid: F4SUUID, hostUuid: F4SUUID) {
        self.uuid = uuid
        self.locationUuid = locationUuid
        self.host = hostUuid
    }
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case locationUuid = "location"
        case host
        case title
        case description
        case started
        case stopped
    }
}

/// Like an AssociationJson but with a full host object rather than a uuid
public struct HostAssociationJson: Codable {
    public let uuid: F4SUUID
    public let locationUuid: F4SUUID
    public let host: Host
    public let title: String?
    public let description: String?
    public let started: String?
    public let stopped: String?
    public var isSelected: Bool = false
    
    public init(uuidAssociation: AssociationJson, host:Host) {
        self.uuid = uuidAssociation.uuid
        self.locationUuid = uuidAssociation.locationUuid
        self.host = host
        self.title = uuidAssociation.title
        self.description = uuidAssociation.description
        self.started = uuidAssociation.started
        self.stopped = uuidAssociation.stopped
        self.isSelected = uuidAssociation.isSelected
    }
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case locationUuid = "location"
        case host
        case title
        case description
        case started
        case stopped
    }
}

public protocol TemplateProviderProtocol: class {
    func fetchCoverLetterTemplateListJson(completion: @escaping ((Result<TemplateListJson,Error>) -> Void))
}

public protocol PicklistProviderProtocol: class {
    var picklistType: PicklistType { get }
    var filters: [URLQueryItem] { get set }
    func fetchPicklistItems(completion: @escaping ((Result<PicklistServerJson,Error>) -> Void))
}

public protocol CompanyWorkplaceListProviderProtocol: class {
    func fetchCompanyWorkplaces(
        locationUuids: [F4SUUID],
        completion: @escaping ((Result<CompanyListJson,Error>) -> Void))
}

public protocol HostsProviderProtocol: class {
    func fetchHost(uuid: String, completion: @escaping (Result<Host,Error>) -> Void)
    func fetchHosts(locationUuid: F4SUUID, completion: @escaping((Result<HostListJson,Error>) -> Void) )
}
