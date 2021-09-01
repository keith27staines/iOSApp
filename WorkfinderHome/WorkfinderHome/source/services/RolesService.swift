
import WorkfinderServices
import WorkfinderCommon

protocol RolesServiceProtocol {
    func fetchFeturedRolesAndRecentRoles(urlString: String?, completion: @escaping (Result<[RoleData], Error>) -> Void)
    func fetchTopRoles(completion: @escaping (Result<[RoleData],Error>) -> Void)
    func fetchRecommendedRoles(completion: @escaping (Result<[RoleData],Error>) -> Void)
    func fetchRolesWithQueryItems(
        _ queryItems: [URLQueryItem],
        completion: @escaping (Result<ServerListJson<RoleData>, Error>) -> Void
    )
    func fetchRolesWithUrl(urlString: String, completion: @escaping (Result<ServerListJson<RoleData>, Error>) -> Void)
    func fetchRecentRoles(urlString: String?, completion: @escaping (Result<ServerListJson<RoleData>,Error>) -> Void)
}

class RolesService: WorkfinderService, RolesServiceProtocol {

    var rolesEndpoint: String  {
        UserRepository().isCandidateLoggedIn ? "projects/candidate_projects/" : "projects/"
    }
    
    fileprivate lazy var topRolesWorkerService: FetchRolesWorkerService = {
        FetchRolesWorkerService(networkConfig: networkConfig)
    }()

    fileprivate lazy var recentRolesWorkerService: FetchRolesResultWorkerService = {
        FetchRolesResultWorkerService(networkConfig: networkConfig)
    }()
    
    fileprivate lazy var rolesWorkerService: FetchRolesResultWorkerService = {
        FetchRolesResultWorkerService(networkConfig: networkConfig)
    }()
    
    fileprivate lazy var recommendationsService: RecommendationsServiceProtocol = {
        RecommendationsService(networkConfig: networkConfig)
    }()
    
    func fetchFeturedRolesAndRecentRoles(urlString: String?, completion: @escaping (Result<[RoleData], Error>) -> Void) {
        fetchTopRoles { [weak self] result in
            switch result {
            case .success(let featuredRolesList):
                guard let self = self else { return }
                self.fetchRecentRoles(urlString: urlString) { result in
                    switch result {
                    case .success(let recentRolesServerList):
                        let combined = featuredRolesList + recentRolesServerList.results
                        completion(.success(combined))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchRecentRoles(urlString: String?, completion: @escaping (Result<ServerListJson<RoleData>, Error>) -> Void) {
        let queryItems = [
            URLQueryItem(name: "promote_on_home_page", value: "false"),
            URLQueryItem(name: "status", value: "open"),
            URLQueryItem(name: "ordering", value: "-created_at")
        ]
        let urlString = urlString?.replacingOccurrences(of: "http:", with: "https:") ?? rolesEndpoint
        recentRolesWorkerService.fetchRoles(endpoint: urlString, queryItems: queryItems) { (result) in
            completion(result)
        }
    }
    
    public func fetchRolesWithQueryItems(
        _ queryItems: [URLQueryItem],
        completion: @escaping (Result<ServerListJson<RoleData>, Error>) -> Void
    ) {
        let queryItems = [
            URLQueryItem(name: "promote_on_home_page", value: "true"),
            URLQueryItem(name: "status", value: "open"),
            URLQueryItem(name: "ordering", value: "-created_at")
        ] + queryItems
        rolesWorkerService.fetchRoles(endpoint: rolesEndpoint, queryItems: queryItems) { (result) in
           completion(result)
        }
    }
    
    public func fetchRolesWithUrl(urlString: String, completion: @escaping (Result<ServerListJson<RoleData>, Error>) -> Void) {
        rolesWorkerService.fetchRoles(endpoint: urlString, queryItems: nil) { (result) in
            completion(result)
        }
    }

    public func fetchTopRoles(completion: @escaping (Result<[RoleData], Error>) -> Void) {
        let queryItems = [
            URLQueryItem(name: "promote_on_home_page", value: "true"),
            URLQueryItem(name: "status", value: "open"),
            URLQueryItem(name: "ordering", value: "-created_at")
        ]
        topRolesWorkerService.fetchRoles(endpoint: rolesEndpoint, queryItems: queryItems) { (result) in
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
}

fileprivate class FetchRolesResultWorkerService: WorkfinderService {
    
    func fetchRoles(endpoint: String, queryItems: [URLQueryItem]?, completion: @escaping (Result<ServerListJson<RoleData>, Error>) -> Void) {
        let innerResultHandler: ((Result<ServerListJson<ProjectJson>, Error>) -> Void) = { result in
            switch result {
            case .success(let json):
                let roleDataArray = json.results.map { (projectJson) -> RoleData in
                    RoleData(project: projectJson)
                }
                let returnResult = ServerListJson<RoleData>(
                    count: json.count,
                    next: json.next,
                    previous: json.previous,
                    results: roleDataArray
                )
                completion(.success(returnResult))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        do {
            let request = try buildRequest(path: endpoint, queryItems: queryItems, verb: .get)
            performTask(with: request, completion: innerResultHandler, attempting: #function)
        } catch {
            completion(.failure(error))
        }
    }
}

fileprivate class FetchRolesWorkerService: WorkfinderService {

    func fetchRoles(endpoint: String, queryItems: [URLQueryItem]?, completion: @escaping (Result<[RoleData], Error>) -> Void) {
        let innerResultHandler: ((Result<ServerListJson<ProjectJson>, Error>) -> Void) = { result in
            switch result {
            case .success(let json):
                let roleDataArray = json.results.map { (projectJson) -> RoleData in
                    RoleData(project: projectJson)
                }
                completion(.success(roleDataArray))
            case .failure(let error):
                completion(.failure(error))
            }
        }

        do {
            let request = try buildRequest(relativePath: endpoint, queryItems: queryItems, verb: .get)
            performTask(with: request, verbose: true  , completion: innerResultHandler, attempting: #function)
        } catch {
            completion(.failure(error))
        }
    }
}
