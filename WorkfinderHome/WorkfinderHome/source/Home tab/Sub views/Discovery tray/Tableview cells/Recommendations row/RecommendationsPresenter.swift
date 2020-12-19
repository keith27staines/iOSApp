
import WorkfinderUI
import WorkfinderServices

class RecommendationsPresenter: CellPresenter {
    
    weak var messageHandler: HSUserMessageHandler?
    let rolesService: RolesServiceProtocol
    
    func load(completion: @escaping (Result<[RoleData],Error>) -> Void) {
        messageHandler?.showLoadingOverlay(style: .transparent)
        rolesService.fetchRecommendedRoles { [weak self] (result) in
            completion(result)
            self?.messageHandler?.hideLoadingOverlay()
        }
    }
    
    var roles: [RoleData] = []
    
    var isSeeMoreCardRequired: Bool { true }
    
    func roleTapped(roleData: RoleData) {
        NotificationCenter.default.post(name: .wfHomeScreenRoleTapped, object: roleData)
    }

    func moreTapped() {
        NotificationCenter.default.post(name: .wfHomeScreenShowRecommendationsTapped, object: self)
    }
    
    init(rolesService: RolesServiceProtocol, messageHandler: HSUserMessageHandler?) {
        self.rolesService = rolesService
        self.messageHandler = messageHandler
    }
}


