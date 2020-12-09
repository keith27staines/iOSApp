
import WorkfinderServices
import WorkfinderCommon

protocol RolesServiceProtocol {
    func fetchTopRoles(completion: @escaping (Result<[RoleData],Error>) -> Void)
    func fetchRecentRoles(completion: @escaping (Result<[RoleData],Error>) -> Void)
    func fetchRecommendedRoles(completion: @escaping (Result<[RoleData],Error>) -> Void)
    func fetchRolesWithQueryItems(
        _ queryItems: [URLQueryItem],
        completion: @escaping (Result<[RoleData], Error>) -> Void
    )
}

class RolesService: WorkfinderService, RolesServiceProtocol {
    
    let rolesEndpoint = "projects/"
    
    fileprivate lazy var topRolesWorkerService: FetchRolesWorkerService = {
        FetchRolesWorkerService(networkConfig: networkConfig)
    }()

    fileprivate lazy var recentRolesWorkerService: FetchRolesWorkerService = {
        FetchRolesWorkerService(networkConfig: networkConfig)
    }()
    
    fileprivate lazy var rolesWorkerService: FetchRolesWorkerService = {
        FetchRolesWorkerService(networkConfig: networkConfig)
    }()
    
    public func fetchRolesWithQueryItems(
        _ queryItems: [URLQueryItem],
        completion: @escaping (Result<[RoleData], Error>) -> Void
    ) {
        let endpointWithQuery = rolesEndpoint
        rolesWorkerService.fetchRoles(endpoint: endpointWithQuery, queryItems: queryItems) { (result) in
           completion(result)
        }
    }

    public func fetchTopRoles(completion: @escaping (Result<[RoleData], Error>) -> Void) {
        let queryItems = [URLQueryItem(name: "promote_on_home_page", value: "True")]
        topRolesWorkerService.fetchRoles(endpoint: rolesEndpoint, queryItems: queryItems) { (result) in
           completion(result)
        }
    }
    
    public func fetchRecentRoles(completion: @escaping (Result<[RoleData], Error>) -> Void) {
        let queryItems = [URLQueryItem(name: "status", value: "open")]
        recentRolesWorkerService.fetchRoles(endpoint: rolesEndpoint, queryItems: queryItems) { (result) in
           completion(result)
        }
    }
    
    public func fetchRecommendedRoles(completion: @escaping (Result<[RoleData],Error>) -> Void) {
        recommendationsService.fetchRecommendations { (result) in
            switch result {
            case .success(let recommendations):
                let roles = recommendations.results.map { (recommendation) -> RoleData in
                    let role = RoleData(recommendation: recommendation)
                    return role
                }
                completion(.success(roles))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    lazy var recommendationsService: RecommendationsServiceProtocol = {
        RecommendationsService(networkConfig: networkConfig)
    }()
}

fileprivate class FetchRolesWorkerService: WorkfinderService {
    
    func fetchRoles(endpoint: String, queryItems: [URLQueryItem]?, completion: @escaping (Result<[RoleData], Error>) -> Void) {
        let innerResultHandler: ((Result<ServerListJson<Role>, Error>) -> Void) = { result in
            switch result {
            case .success(let json):
                let roleDataArray = json.results.map { (role) -> RoleData in
                    RoleData(role: role)
                }
                completion(.success(roleDataArray))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        do {
            let request = try buildRequest(relativePath: endpoint, queryItems: queryItems, verb: .get)
            performTask(with: request, completion: innerResultHandler, attempting: #function)
        } catch {
            completion(.failure(error))
        }
    }
}

fileprivate struct Role: Codable {
    var uuid: F4SUUID?
    var name: String?
    var association: ExpandedAssociation
    var is_remote: Bool?
    var is_paid: Bool?
    var employment_type: String?
}

fileprivate extension RoleData {
    init(role: Role) {
        id = role.uuid
        projectTitle = role.name
        companyName = role.association.location?.company?.name
        companyLogoUrlString = role.association.location?.company?.logo
        locationHeader = "Location"
        location = role.is_remote == true ? "Remote" : ""
        paidHeader = "Paid (ph)"
        paidAmount = role.is_paid == true ? "£6 - 8.21" : "Voluntary"
        actionButtonText = "Apply now"
        workingHours = role.employment_type
    }
}
