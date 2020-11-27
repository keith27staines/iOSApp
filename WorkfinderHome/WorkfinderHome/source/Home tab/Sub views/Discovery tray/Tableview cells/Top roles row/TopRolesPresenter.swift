
class TopRolesPresenter: CellPresenter {
    
    lazy var rolesService: RolesServiceProtocol = RolesService()
    
    func load(completion: @escaping (Result<[RoleData],Error>) -> Void) {
        rolesService.fetchRoles { (result) in
            completion(result)
        }
    }
    
    var roles: [RoleData] = []
    
    func roleTapped(id: String) {
        print("tapped role: \(id)")
    }
}
