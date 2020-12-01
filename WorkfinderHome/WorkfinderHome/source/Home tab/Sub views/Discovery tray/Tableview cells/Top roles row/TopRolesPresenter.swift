
class TopRolesPresenter: CellPresenter {
    
    let rolesService: RolesServiceProtocol
    
    func load(completion: @escaping (Error?) -> Void) {
        rolesService.fetchTopRoles { (result) in
            switch result {
            case .success(let roles):
                self.roles = ([RoleData](roles[0..<10])).map({ (roleData) -> RoleData in
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
    
    func roleTapped(id: String) {
        print("tapped role: \(id)")
    }
    
    init(rolesService: RolesServiceProtocol) {
        self.rolesService = rolesService
    }
}
