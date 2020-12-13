import WorkfinderCommon
import WorkfinderServices

protocol ApplicationDetailServiceProtocol: AnyObject {
    func fetchApplicationDetail(application: Application, completion: @escaping (Result<Application,Error>)-> Void)
}

class ApplicationDetailService: WorkfinderService, ApplicationDetailServiceProtocol {
    
    func fetchApplicationDetail(application: Application, completion: @escaping (Result<Application,Error>)-> Void) {
        
        performNetworkRequest(placementUuid: application.placementUuid) { (result) in
            switch result {
            case .success(let placement):
                let applicationDetail = Application(json: placement)
                completion(.success(applicationDetail))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        completion(.success(application))
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
