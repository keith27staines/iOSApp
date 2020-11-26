
class TopRolesPresenter: CellPresenter {
    var roles: [RoleData] = [
        RoleData(id: "1", logoUrlString: nil, projectTitle: "Competitor Analysis Review", paidHeader: "paid (ph)", paidAmount: "£6 - 8.21", locationHeader: "Location", location: "Remote", actionButtonText: "Apply now"),
        RoleData(id: "2", logoUrlString: nil, projectTitle: "Competitor Analysis Review", paidHeader: "paid (ph)", paidAmount: "£6 - 8.21", locationHeader: "Location", location: "Remote", actionButtonText: "Apply now"),
        RoleData(id: "3", logoUrlString: nil, projectTitle: "Competitor Analysis Review", paidHeader: "paid (ph)", paidAmount: "£6 - 8.21", locationHeader: "Location", location: "Remote", actionButtonText: "Apply now"),
        RoleData(id: "4", logoUrlString: nil, projectTitle: "Competitor Analysis Review", paidHeader: "paid (ph)", paidAmount: "£6 - 8.21", locationHeader: "Location", location: "Remote", actionButtonText: "Apply now"),
        RoleData(id: "5", logoUrlString: nil, projectTitle: "Competitor Analysis Review", paidHeader: "paid (ph)", paidAmount: "£6 - 8.21", locationHeader: "Location", location: "Remote", actionButtonText: "Apply now"),
        RoleData(id: "6", logoUrlString: nil, projectTitle: "Competitor Analysis Review", paidHeader: "paid (ph)", paidAmount: "£6 - 8.21", locationHeader: "Location", location: "Remote", actionButtonText: "Apply now"),
        RoleData(id: "7", logoUrlString: nil, projectTitle: "Competitor Analysis Review", paidHeader: "paid (ph)", paidAmount: "£6 - 8.21", locationHeader: "Location", location: "Remote", actionButtonText: "Apply now"),
        RoleData(id: "8", logoUrlString: nil, projectTitle: "Competitor Analysis Review", paidHeader: "paid (ph)", paidAmount: "£6 - 8.21", locationHeader: "Location", location: "Remote", actionButtonText: "Apply now"),
        RoleData(id: "9", logoUrlString: nil, projectTitle: "Competitor Analysis Review", paidHeader: "paid (ph)", paidAmount: "£6 - 8.21", locationHeader: "Location", location: "Remote", actionButtonText: "Apply now"),
        RoleData(id: "10", logoUrlString: nil, projectTitle: "Competitor Analysis Review", paidHeader: "paid (ph)", paidAmount: "£6 - 8.21", locationHeader: "Location", location: "Remote", actionButtonText: "Apply now"),
    ]
    
    func roleTapped(id: String) {
        print("tapped role: \(id)")
    }
}
