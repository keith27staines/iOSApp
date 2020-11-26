
class RecommendationsPresenter: CellPresenter {
    var roles: [RoleData] = [
        RoleData(id: "1", logoUrlString: nil, projectTitle: "Competitor Analysis Review", paidHeader: "paid (ph)", paidAmount: "£6 - 8.21", locationHeader: "Location", location: "Remote", actionButtonText: "Discover more"),
        RoleData(id: "2", logoUrlString: nil, projectTitle: "Competitor Analysis Review", paidHeader: "paid (ph)", paidAmount: "£6 - 8.21", locationHeader: "Location", location: "Remote", actionButtonText: "Discover more"),
        RoleData(id: "3", logoUrlString: nil, projectTitle: "Competitor Analysis Review", paidHeader: "paid (ph)", paidAmount: "£6 - 8.21", locationHeader: "Location", location: "Remote", actionButtonText: "Discover more"),
    ]
    
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

struct RoleData {
    var id: String?
    var logoUrlString: String?
    var projectTitle: String?
    var paidHeader: String?
    var paidAmount: String?
    var locationHeader: String?
    var location: String?
    var actionButtonText: String?
}
