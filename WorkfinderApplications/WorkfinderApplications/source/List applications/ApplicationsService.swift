import WorkfinderCommon
import WorkfinderServices

protocol ApplicationsServiceProtocol: AnyObject {
    func fetchAllApplications(completion: @escaping (Result<ServerListJson<Application>,Error>) -> Void)
    func fetchNextPage(urlString: String, completion: @escaping (Result<ServerListJson<Application>,Error>) -> Void )
    //func fetchApplicationsWithOpenOffer(completion: @escaping (Result<ServerListJson<Application>,Error>) -> Void)
    func fetchInterviews(completion: @escaping (Result<[InterviewJson],Error>) -> Void)
}

class ApplicationsService: WorkfinderService, ApplicationsServiceProtocol {
        
    override init(networkConfig: NetworkConfig) {
        super.init(networkConfig: networkConfig)
    }
    
    private lazy var interviewService: InterviewServiceProtocol = {
        InterviewService(networkConfig: networkConfig)
    }()
        
    func fetchInterviews(completion: @escaping (Result<[InterviewJson], Error>) -> Void) {
        interviewService.fetchInterviews(completion: completion)
    }
    
    func fetchAllApplications(completion: @escaping (Result<ServerListJson<Application>, Error>) -> Void) {
        fetchApplications(queryItems: [], completion: completion)
    }
    
//    func fetchApplicationsWithOpenOffer(completion: @escaping (Result<ServerListJson<Application>, Error>) -> Void) {
//        let offerQueryItems = [URLQueryItem(name: "status", value: "offered"),URLQueryItem(name: "status", value: "interview offered")]
//        fetchApplications(queryItems: offerQueryItems, completion: completion)
//    }
    
    private func fetchApplications(queryItems: [URLQueryItem], completion: @escaping (Result<ServerListJson<Application>,Error>) -> Void) {
        performfetchApplications(queryItems: queryItems) { [weak self] (networkResult) in
            guard let self = self else { return }
            let applicationsResult = self.buildApplicationsResult(networkResult: networkResult)
            completion(applicationsResult)
        }
    }
    
    func fetchNextPage(urlString: String, completion: @escaping (Result<ServerListJson<Application>, Error>) -> Void) {
        
    }

    private func performfetchApplications(queryItems: [URLQueryItem] = [], completion: @escaping (Result<ServerListJson<ApplicationJson>,Error>) -> Void) {
        do {
            let relativePath = "placements/"
            let queryItems = [URLQueryItem(name: "expand-association", value: "1")] + queryItems
            let request = try buildRequest(relativePath: relativePath, queryItems: queryItems, verb: .get)
            performTask(
                with: request,
                verbose: true,
                completion: completion,
                attempting: #function)
        } catch {
            completion(.failure(error))
        }
    }
    
    private func buildApplicationsResult(networkResult: Result<ServerListJson<ApplicationJson>,Error>)
        -> Result<ServerListJson<Application>, Error> {
            switch networkResult {
            case .success(let serverList):
                var applications = [Application]()
                let expandedPlacements = serverList.results
                expandedPlacements.forEach { (placement) in
                    applications.append(Application(json: placement))
                }
                return .success(ServerListJson<Application>(count: serverList.count, next: serverList.next, previous: serverList.previous, results: applications))
            case .failure(let error):
                return .failure(error)
            }
    }
}

struct PlacementJson: Codable {
    var uuid: F4SUUID?
    var status: String?
    var created_at: String?
    var cover_letter: String?
    var association: ExpandedAssociation?
    var start_date: String?
    var end_date: String?
    var offered_duration: Int?
    var offer_notes: String?
    var salary: String?
    var supporting_link: String?
    var associated_project: AssociatedProject?
}

struct AssociatedProject: Codable {
    var uuid: F4SUUID?
    var employmentType: String?
    var isPaid: Bool?
    var isRemote: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case employmentType = "employment_type"
        case isPaid = "is_paid"
        case isRemote = "is_remote"
    }
}

struct ApplicationJson: Codable {
    var uuid: F4SUUID?
    var status: String?
    var created_at: String?
    var cover_letter: String?
    var association: ExpandedAssociation?
    var start_date: String?
    var end_date: String?
    var offered_duration: Int?
    var offer_notes: String?
    var salary: String?
    var supporting_link: String?
    var associated_project: F4SUUID?
    var associated_project_name: String?
}

