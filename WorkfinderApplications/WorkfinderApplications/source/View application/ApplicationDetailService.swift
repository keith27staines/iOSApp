import WorkfinderCommon
import WorkfinderServices

protocol ApplicationDetailServiceProtocol: AnyObject {
    func fetchApplicationDetail(application: Application, completion: @escaping (Result<ApplicationDetail,Error>)-> Void)
}

class ApplicationDetailService: WorkfinderService, ApplicationDetailServiceProtocol {
    
    func fetchApplicationDetail(application: Application, completion: @escaping (Result<ApplicationDetail,Error>)-> Void) {
        
        performNetworkRequest(placementUuid: application.placementUuid) { (result) in
            switch result {
            case .success(let placement):
                let applicationDetail = ApplicationDetail(json: placement)
                completion(Result<ApplicationDetail,Error>.success(applicationDetail))
            case .failure(let error):
                completion(Result<ApplicationDetail,Error>.failure(error))
            }
        }
        completion(Result<ApplicationDetail,Error>.success(application))
    }
    
    func performNetworkRequest(placementUuid: F4SUUID, completion: @escaping (Result<ExpandedAssociationPlacementJson, Error>) -> Void) {
        let relativePath = "placements/\(placementUuid)"
        let queryItems = [URLQueryItem(name: "expand-association", value: "1")]
        do {
            let request = try buildRequest(relativePath: relativePath, queryItems: queryItems, verb: .get)
            performTask(with: request,
                        completion: completion,
                        attempting: #function)
        } catch {
            completion(Result<ExpandedAssociationPlacementJson,Error>.failure(error))
        }
    }
}
