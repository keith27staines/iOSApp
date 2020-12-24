
import WorkfinderUI

class TopRolesPresenter: CellPresenter {
    weak var messageHandler: HSUserMessageHandler?
    let rolesService: RolesServiceProtocol
    
    func load(completion: @escaping (Error?) -> Void) {
        messageHandler?.showLoadingOverlay(style: .transparent)
        rolesService.fetchTopRoles { [weak self] (result) in
            guard let self = self else { return }
            self.messageHandler?.hideLoadingOverlay()
            switch result {
            case .success(let roles):
                let maxRoles = min(10, roles.count)
                self.roles = ([RoleData](roles[0..<maxRoles])).map({ (roleData) -> RoleData in
                    var adaptedData = roleData
                    adaptedData.actionButtonText = "Discover more"
                    return adaptedData
                }).settingAppSource(.homeTabTopRoles)
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    var roles: [RoleData] = []
    
    func roleTapped(roleData: RoleData) {
        NotificationCenter.default.post(name: .wfHomeScreenRoleTapped, object: roleData)
    }
    
    init(rolesService: RolesServiceProtocol, messageHandler: HSUserMessageHandler?) {
        self.rolesService = rolesService
        self.messageHandler = messageHandler
    }
}
