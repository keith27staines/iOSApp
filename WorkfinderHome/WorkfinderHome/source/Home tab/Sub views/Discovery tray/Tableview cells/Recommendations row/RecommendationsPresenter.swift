import WorkfinderCommon
import WorkfinderUI
import WorkfinderServices

class RecommendationsPresenter: CellPresenter {
    
    enum LastCardType {
        case none
        case noRecommendationsYet
        case moreRecommendations
        var title: String {
            switch self {
            case .none: return ""
            case .noRecommendationsYet: return "No recommendations yet"
            case .moreRecommendations: return "See more recommendations"
            }
        }
    }
    
    weak var messageHandler: HSUserMessageHandler?
    let rolesService: RolesServiceProtocol
    var result: Result<[RoleData],Error>?
    
    func load(completion: @escaping (Result<[RoleData],Error>) -> Void) {
        messageHandler?.showLoadingOverlay(style: .transparent)
        rolesService.fetchRecommendedRoles { [weak self] (result) in
            self?.result = result
            completion(result)
            self?.messageHandler?.hideLoadingOverlay()
        }
    }
    
    var roles: [RoleData] = []
    
    var lastCardType: LastCardType {
        guard let result = result else { return .none}
        switch result {
        case .success(let data):
            let count = data.count
            return count > 9 ? .moreRecommendations : count > 0 ? .none : .noRecommendationsYet
        case .failure(_): return .none
        }
    }
    
    func roleTapped(roleData: RoleData) {
        NotificationCenter.default.post(name: .wfHomeScreenRoleTapped, object: roleData)
    }

    func moreTapped() {
        guard lastCardType == .moreRecommendations else { return }
        NotificationCenter.default.post(name: .wfHomeScreenShowRecommendationsTapped, object: self)
    }
    
    init(rolesService: RolesServiceProtocol, messageHandler: HSUserMessageHandler?) {
        self.rolesService = rolesService
        self.messageHandler = messageHandler
    }
}


