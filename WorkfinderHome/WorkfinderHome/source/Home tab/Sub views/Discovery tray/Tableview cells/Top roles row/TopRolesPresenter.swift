
class TopRolesPresenter: CellPresenter {
    
    let rolesService: RolesServiceProtocol
    
    func load(completion: @escaping (Error?) -> Void) {
        rolesService.fetchTopRoles { (result) in
            switch result {
            case .success(let roles):
                let maxRoles = min(10, roles.count)
                self.roles = ([RoleData](roles[0..<maxRoles])).map({ (roleData) -> RoleData in
                    var adaptedData = roleData
                    adaptedData.actionButtonText = "Discover more"
                    return adaptedData
                })
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
    
    init(rolesService: RolesServiceProtocol) {
        self.rolesService = rolesService
    }
}
