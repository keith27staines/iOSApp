


class RecommendationsPresenter: CellPresenter {
    
    lazy var rolesService: RolesServiceProtocol = RolesService()
    
    func load(completion: @escaping (Result<[RoleData],Error>) -> Void) {
        rolesService.fetchRoles { (result) in
            completion(result)
        }
    }
    
    var roles: [RoleData] = []
    
    var isMoreCardRequired: Bool {
        true
    }
    
    func roleTapped(id: String) {
        print("tapped role: \(id)")
    }
    
    func moreTapped() {
        print("tapped \"See more\"")
    }
}
