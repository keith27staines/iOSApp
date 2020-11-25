
class RecommendationsPresenter: CellPresenter {
    var roles: [RoleData] = [
        RoleData(id: "1", logoUrlString: nil, projectTitle: "Project Title", paidHeader: "paid (ph)", paidAmount: "£6 - 8.21", locationHeader: "Location", location: "Remote"),
        RoleData(id: "2", logoUrlString: nil, projectTitle: "Project Title", paidHeader: "paid (ph)", paidAmount: "£6 - 8.21", locationHeader: "Location", location: "Remote"),
        RoleData(id: "3", logoUrlString: nil, projectTitle: "Project Title", paidHeader: "paid (ph)", paidAmount: "£6 - 8.21", locationHeader: "Location", location: "Remote"),
        RoleData(id: "4", logoUrlString: nil, projectTitle: "Project Title", paidHeader: "paid (ph)", paidAmount: "£6 - 8.21", locationHeader: "Location", location: "Remote"),
        RoleData(id: "5", logoUrlString: nil, projectTitle: "Project Title", paidHeader: "paid (ph)", paidAmount: "£6 - 8.21", locationHeader: "Location", location: "Remote"),
        RoleData(id: "6", logoUrlString: nil, projectTitle: "Project Title", paidHeader: "paid (ph)", paidAmount: "£6 - 8.21", locationHeader: "Location", location: "Remote"),
        RoleData(id: "7", logoUrlString: nil, projectTitle: "Project Title", paidHeader: "paid (ph)", paidAmount: "£6 - 8.21", locationHeader: "Location", location: "Remote"),
        RoleData(id: "8", logoUrlString: nil, projectTitle: "Project Title", paidHeader: "paid (ph)", paidAmount: "£6 - 8.21", locationHeader: "Location", location: "Remote"),
        RoleData(id: "9", logoUrlString: nil, projectTitle: "Project Title", paidHeader: "paid (ph)", paidAmount: "£6 - 8.21", locationHeader: "Location", location: "Remote"),
        RoleData(id: "10", logoUrlString: nil, projectTitle: "Project Title", paidHeader: "paid (ph)", paidAmount: "£6 - 8.21", locationHeader: "Location", location: "Remote"),
    ]
}

struct RoleData {
    var id: String?
    var logoUrlString: String?
    var projectTitle: String?
    var paidHeader: String?
    var paidAmount: String?
    var locationHeader: String?
    var location: String?
}
