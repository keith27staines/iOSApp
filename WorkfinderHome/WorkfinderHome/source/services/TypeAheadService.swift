
import Foundation
import WorkfinderServices

protocol TypeAheadServiceProtocol {
    func fetch(queryItems: [URLQueryItem], completion: @escaping (Result<TypeAheadJson,Error>) -> Void)
}

class TypeAheadService: WorkfinderService, TypeAheadServiceProtocol {
    
    func
    fetch(queryItems: [URLQueryItem], completion: @escaping (Result<TypeAheadJson,Error>) -> Void) {
        do {
            let endpoint = "search/typeahead/"
            let request = try buildRequest(relativePath: endpoint, queryItems: queryItems, verb: .get)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(.failure(error))
        }
    }
}
    

