
protocol RolesServiceProtocol {
    func fetchRoles(completion: @escaping (Result<[RoleData],Error>) -> Void)
}

class RolesService: RolesServiceProtocol {
    
    let roles: [RoleData] = [
        RoleData(id: "1", roleLogoUrlString: nil, projectTitle: "Competitor Analysis Review", paidHeader: "paid (ph)", paidAmount: "£6 - 8.21", locationHeader: "Location", location: "Remote", actionButtonText: "Discover more"),
        RoleData(id: "2", roleLogoUrlString: nil, projectTitle: "Competitor Analysis Review", paidHeader: "paid (ph)", paidAmount: "£6 - 8.21", locationHeader: "Location", location: "Remote", actionButtonText: "Discover more"),
        RoleData(id: "3", roleLogoUrlString: nil, projectTitle: "Competitor Analysis Review", paidHeader: "paid (ph)", paidAmount: "£6 - 8.21", locationHeader: "Location", location: "Remote", actionButtonText: "Discover more"),
    ]
    
    func fetchRoles(completion: @escaping (Result<[RoleData],Error>) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let roles = self?.roles else { return }
            completion(Result.success(roles))
        }
    }
}
