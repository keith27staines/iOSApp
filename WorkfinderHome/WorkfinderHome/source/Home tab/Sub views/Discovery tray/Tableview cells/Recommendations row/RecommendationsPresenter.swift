
import WorkfinderServices

class RecommendationsPresenter: CellPresenter {
    
    let rolesService: RolesServiceProtocol
    
    func load(completion: @escaping (Result<[RoleData],Error>) -> Void) {
        rolesService.fetchRecommendedRoles { (result) in
            completion(result)
        }
    }
    
    var roles: [RoleData] = []
    
    var isSeeMoreCardRequired: Bool { true }
    
    func roleTapped(roleData: RoleData) {
        NotificationCenter.default.post(name: .wfHomeScreenRoleTapped, object: roleData)
    }
    
    func moreTapped() {
        print("tapped \"See more\"")
    }
    
    init(rolesService: RolesServiceProtocol) {
        self.rolesService = rolesService
    }
}


