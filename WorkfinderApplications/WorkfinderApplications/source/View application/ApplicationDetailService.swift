import WorkfinderCommon
import WorkfinderServices

protocol PlacementDetailServiceProtocol: AnyObject {
    func fetchApplication(placementUuid: F4SUUID, completion: @escaping (Result<Application,Error>)-> Void)
}

class ApplicationDetailService: WorkfinderService, PlacementDetailServiceProtocol {
    
    func fetchApplication(placementUuid: F4SUUID, completion: @escaping (Result<Application,Error>)-> Void) {
        
        performNetworkRequest(placementUuid: placementUuid) { (result) in
            switch result {
            case .success(let placement):
                let application = Application(json: placement)
                completion(.success(application))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func performNetworkRequest(placementUuid: F4SUUID, completion: @escaping (Result<PlacementJson, Error>) -> Void) {
        let relativePath = "placements/\(placementUuid)"
        let queryItems = [URLQueryItem(name: "expand-association", value: "1")]
        do {
            let request = try buildRequest(relativePath: relativePath, queryItems: queryItems, verb: .get)
            performTask(with: request,
                        completion: completion,
                        attempting: #function)
        } catch {
            completion(Result<PlacementJson,Error>.failure(error))
        }
    }
}
