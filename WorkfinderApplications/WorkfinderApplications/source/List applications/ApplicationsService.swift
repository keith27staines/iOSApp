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
    typealias ExpandedList = ServerListJson<ExpandedAssociationPlacementJson>
    func performNetworkRequest(completion: @escaping (Result<ExpandedList,Error>) -> Void) {
        do {
            let relativePath = "placements/"
            let queryItems = [URLQueryItem(name: "expand-association", value: "1")]
            let request = try buildRequest(relativePath: relativePath, queryItems: queryItems, verb: .get)
            performTask(
                with: request,
                completion: completion,
                attempting: #function)
        } catch {
            completion(Result<ExpandedList,Error>.failure(error))
        }
    }
    
    func buildApplicationsResult(networkResult: Result<ExpandedList,Error>)
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

extension Application {
    init(json: ExpandedAssociationPlacementJson) {
        self.placementUuid = json.uuid
        self.companyUuid = json.association?.location?.company?.uuid
        self.hostUuid = json.association?.host?.uuid
        self.associationUuid = json.association?.uuid
        self.state = ApplicationState(string: json.status)
        self.hostName = json.association?.host?.full_name ?? "unknown name"
        self.hostRole = json.association?.title ?? "unknown role"
        self.companyName = json.association?.location?.company?.name ?? "unknown company"
        self.industry = json.association?.location?.company?.industry?.first?.name
        self.logoUrl = json.association?.location?.company?.logo
        self.appliedDate = json.created_at ?? "1700-01-01"
        self.coverLetterString = ""
        
    }
}
/*
 PENDING = "pending"
 EXPIRED = "expired"
 VIEWED = "viewed"
 DECLINED = "declined"
 SAVED = "saved"
 OFFERED = "offered"
 ACCEPTED = "accepted"
 WITHDRAWN = "withdrawn"
 */
extension ApplicationState {
    init(string: String?) {
        guard let string = string else {
            self = .unknown
            return
        }
        switch string {
        case "pending": self = .applied
        case "expired": self = .expired
        case "viewed": self = .viewedByHost
        case "declined": self = .applicationDeclined
        case "saved": self = .savedByHost
        case "offered": self = .offerMade
        case "accepted": self = .offerAccepted
        case "withdrawn": self = .candidateWithdrew
        default: self = .unknown
        }
    }
}

/*
 {
     "uuid": "d5ec2fea-8222-4bb3-a65b-7c0ac8eac5f7",
     "association": {
         "uuid": "33dcfe67-1368-433f-ae9c-160fb890b0fe",
         "host": {
             "uuid": "4803ecb1-705c-4990-81a0-cb945f7a0f71",
             "full_name": "DerivedHost"
         },
         "location": {
             "uuid": "8a9623e6-e29a-4cac-8622-20819a2d8f0e",
             "company": {
                 "uuid": "2acea251-b6d6-4f53-ad98-564142a929d8",
                 "name": "DerivedCompany",
                 "logo": null,
                 "industries": []
             }
         },
         "title": "DerivedAssociation"
     },
     "status": "pending",
     "created_at": "2020-05-21T08:22:31.368585Z"
 }
 */
struct ExpandedAssociationPlacementJson: Codable {
    var uuid: F4SUUID?
    var status: String?
    var created_at: String?
    var association: Association?
    
    struct Association: Codable
    {
        var uuid: F4SUUID?
        var title: String?
        var host: Host?
        var location: Location?
        struct Host: Codable {
            var uuid: F4SUUID?
            var full_name: String?
        }
        struct Location: Codable {
            var uuid: F4SUUID?
            var company: Company?
            
            struct Company: Codable {
                var uuid: String?
                var name: String?
                var logo: String?
                var industry: [Industry]?
                struct Industry: Codable {
                    var uuid: F4SUUID?
                    var name: String?
                }
            }
        }
    }
}
