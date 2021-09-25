import WorkfinderCommon
import WorkfinderServices

protocol PlacementDetailServiceProtocol: AnyObject {
    func fetchApplication(placementUuid: F4SUUID, completion: @escaping (Result<Application,Error>)-> Void)
}

class ApplicationDetailService: WorkfinderService, PlacementDetailServiceProtocol {
    
    private lazy var interviewService: InterviewService = {
        InterviewService(networkConfig: networkConfig)
    }()
    
    private func fetchInterviewForPlacement(placementUuid: F4SUUID, completion: @escaping (Result<InterviewJson?, Error>) -> Void) {
        interviewService.fetchInterviews { result in
            switch result {
            case .success(let interviews):
                let interview = interviews.first { interview in
                    interview.placement?.uuid == placementUuid
                }
                completion(.success(interview))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchApplication(placementUuid: F4SUUID, completion: @escaping (Result<Application,Error>)-> Void) {        
        performNetworkRequest(placementUuid: placementUuid) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let applicationJson):
                let placementJson = PlacementJson(json: applicationJson)
                var application = Application(json: placementJson)
                self.fetchInterviewForPlacement(placementUuid: placementUuid) { result in
                    switch result {
                    case.success(let interviewJson):
                        application.interviewJson = interviewJson
                        completion(.success(application))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func performNetworkRequest(placementUuid: F4SUUID, completion: @escaping (Result<ApplicationJson, Error>) -> Void) {
        let relativePath = "placements/\(placementUuid)"
        let queryItems = [URLQueryItem(name: "expand-association", value: "1")]
        do {
            let request = try buildRequest(relativePath: relativePath, queryItems: queryItems, verb: .get)
            performTask(with: request,
                        verbose: true,
                        completion: completion,
                        attempting: #function)
        } catch {
            completion(Result<ApplicationJson,Error>.failure(error))
        }
    }
    
}
