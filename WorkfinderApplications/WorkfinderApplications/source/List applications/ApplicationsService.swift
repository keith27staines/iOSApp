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
        self.placementUuid = json.uuid ?? "unknown uuid"
        self.companyUuid = json.association?.location?.company?.uuid
        self.hostUuid = json.association?.host?.uuid
        self.associationUuid = json.association?.uuid
        self.state = ApplicationState(string: json.status)
        self.hostName = json.association?.host?.displayName ?? "unknown name"
        self.hostRole = json.association?.title ?? "unknown role"
        self.companyName = json.association?.location?.company?.name ?? "unknown company"
        self.industry = json.association?.location?.company?.industries?.first?.name
        self.logoUrl = json.association?.location?.company?.logo
        self.appliedDate = json.created_at ?? "1700-01-01"
        self.coverLetterString = json.cover_letter ?? ""
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

struct ExpandedAssociationPlacementJson: Codable {
    var uuid: F4SUUID?
    var status: String?
    var created_at: String?
    var cover_letter: String?
    var association: Association?
    var start_date: String?
    var offered_duration: Int?
    var offer_notes: String?
    
    struct Association: Codable {
        var uuid: F4SUUID?
        var title: String?
        var host: Host?
        var location: Location?
        struct Location: Codable {
            var uuid: F4SUUID?
            var company: CompanyJson?
            var address_unit: String?
            var address_building: String?
            var address_street: String?
            var address_city: String?
            var address_region: String?
            var address_postcode: String?
            var address_country: CodeAndName?
            struct CodeAndName: Codable {
                var code: String
                var name: String
            }
        }
    }
}
