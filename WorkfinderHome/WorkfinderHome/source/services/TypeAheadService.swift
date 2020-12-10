
import Foundation
import WorkfinderServices

protocol TypeAheadServiceProtocol {
    func fetch(queryItems: [URLQueryItem], completion: @escaping (Result<TypeAheadJson,Error>) -> Void)
}

class TypeAheadService: WorkfinderService, TypeAheadServiceProtocol {
    
    func fetch(queryItems: [URLQueryItem], completion: @escaping (Result<TypeAheadJson,Error>) -> Void) {
        do {
            let endpoint = "search/typeahead/"
            let request = try buildRequest(relativePath: endpoint, queryItems: queryItems, verb: .get)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(.failure(error))
        }
    }
}

struct TypeAheadJson : Codable {
    var count: Int
    var projects: [TypeAheadItem]?
    var companies: [TypeAheadItem]?
    var people: [TypeAheadItem]?
    
    private enum CodingKeys: String, CodingKey {
        case count
        case projects
        case companies
        case people = "associations"
    }
}
    
struct TypeAheadItem: Codable {
    var uuid: String?
    var title: String?
    var subtitle: String?
    var searchTerm: String?
    var objectType: String?
    var iconUrlString: String?
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case title = "name"
        case subtitle = "label"
        case searchTerm = "search_term"
        case objectType = "object_type"
        case iconUrlString = "icon"
    }
}
