
import Foundation

public protocol HostLocationAssociationsServiceProtocol {
    func fetchAssociations(for locationUuid: F4SUUID, completion:  @escaping((Result<HostLocationAssociationListJson,Error>) -> Void))
}

/*
 {
     "uuid": "ebcc26fe-f9d6-455e-8dcf-35e97686f12d",
     "host": {
         "uuid": "389efb7e-daa9-413f-a3cb-c9dc5c520fef",
         "full_name": "Steven Gee",
         "names": [
             "Steven Gee"
         ],
         "emails": [],
         "user": null,
         "photo": "https://api-workfinder-com-develop.s3.amazonaws.com/develop/media/hosts/derived/389efb7e-daa9-413f-a3cb-c9dc5c520fef.jpg",
         "phone": "",
         "instagram_handle": "",
         "twitter_handle": "",
         "linkedin_url": "https://www.linkedin.com/in/steven-gee-8259681",
         "description": "",
         "associations": [
             "ebcc26fe-f9d6-455e-8dcf-35e97686f12d"
         ]
     },
     "location": "4e60e978-de84-452a-b1a6-a5a02b02d30a",
     "title": "Owner",
     "started": "2000-01-01",
     "stopped": null,
     "description": ""
 }
 
 */

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
    public let started: Date?
    public let stopped: Date?
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case locationUuid = "location_uuid"
        case host
        case title
        case description
        case started
        case stopped
    }
}

public protocol ApplyServiceProtocol: class {
    
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
