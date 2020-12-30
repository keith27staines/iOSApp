import WorkfinderCommon
import WorkfinderServices

protocol ApplicationsServiceProtocol: AnyObject {
    func fetchApplications(completion: @escaping (Result<[Application],Error>) -> Void)
}

class ApplicationsService: WorkfinderService, ApplicationsServiceProtocol {

    func fetchApplications(completion: @escaping (Result<[Application],Error>) -> Void) {
        performNetworkRequest { [weak self] (networkResult) in
            guard let self = self else { return }
            let applicationsResult = self.buildApplicationsResult(networkResult: networkResult)
            completion(applicationsResult)
        }
    }

    private func performNetworkRequest(completion: @escaping (Result<ServerListJson<PlacementJson>,Error>) -> Void) {
        do {
            let relativePath = "placements/"
            let queryItems = [URLQueryItem(name: "expand-association", value: "1")]
            let request = try buildRequest(relativePath: relativePath, queryItems: queryItems, verb: .get)
            performTask(
                with: request,
                completion: completion,
                attempting: #function)
        } catch {
            completion(.failure(error))
        }
    }
    
    private func buildApplicationsResult(networkResult: Result<ServerListJson<PlacementJson>,Error>)
        -> Result<[Application], Error> {
            switch networkResult {
            case .success(let serverList):
                var applications = [Application]()
                let expandedPlacements = serverList.results
                expandedPlacements.forEach { (placement) in
                    applications.append(Application(json: placement))
                }
                return Result<[Application],Error>.success(applications)
            case .failure(let error):
                return Result<[Application],Error>.failure(error)
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
    var is_remote: Bool?
    var salary: String?
    var supporting_link: String?
}
