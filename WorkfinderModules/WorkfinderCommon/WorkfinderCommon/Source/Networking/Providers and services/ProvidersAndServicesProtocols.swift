
import Foundation

public protocol HostLocationAssociationsServiceProtocol {
    func fetchAssociations(for locationUuid: F4SUUID, completion:  @escaping((Result<HostLocationAssociationListJson,Error>) -> Void))
}

public struct ServerListJson<A:Decodable>: Decodable {
    public var count: Int?
    public var next: String?
    public var previous: String?
    public let results: [A]
}

public struct HostLocationAssociationJson: Codable {
    public let uuid: F4SUUID
    public let locationUuid: F4SUUID
    public let host: Host
    public let title: String?
    public let description: String?
    public let started: String?
    public let stopped: String?
    public var isSelected: Bool = false
    
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
    func fetchPicklistItems(completion: @escaping ((Result<PicklistServerJson,Error>) -> Void))
}

public protocol CompanyWorkplaceListProviderProtocol: class {
    func fetchCompanyWorkplaces(
        locationUuids: [F4SUUID],
        completion: @escaping ((Result<CompanyListJson,Error>) -> Void))
}

public protocol HostsProviderProtocol: class {
    func fetchHosts(locationUuid: F4SUUID, completion: @escaping((Result<HostListJson,Error>) -> Void) )
}
