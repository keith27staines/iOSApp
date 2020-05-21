
protocol ApplicationsServiceProtocol: AnyObject {
    func fetchApplications(completion: @escaping (Result<[Application],Error>) -> Void)
}

class ApplicationsService: ApplicationsServiceProtocol {
    func fetchApplications(completion: @escaping (Result<[Application],Error>) -> Void) {
        let applications: [Application] = [
//            Application(state: .applicationDeclined, hostName: "Host 1", hostRole: "Role 1", companyName: "Company 1", industry: "Industry 1", logoUrl: nil, appliedDate: "08-Mar-2020", coverLetterString: coverLetterText),
//            Application(state: .applied, hostName: "Host 2", hostRole: "Role 2", companyName: "Company 2", industry: "Industry 2", logoUrl: nil, appliedDate: "08-Mar-2020", coverLetterString: coverLetterText),
//            Application(state: .offerAccepted, hostName: "Host 3", hostRole: "Role 3", companyName: "Company 3", industry: "Industry 3", logoUrl: nil, appliedDate: "08-Mar-2020", coverLetterString: coverLetterText),
//            Application(state: .offerDeclined, hostName: "Host 4", hostRole: "Role 4", companyName: "Company 4", industry: "Industry 4", logoUrl: nil, appliedDate: "08-Mar-2020", coverLetterString: coverLetterText),
//            Application(state: .offerMade, hostName: "Host 5", hostRole: "Role 5", companyName: "Company 5", industry: "Industry 5", logoUrl: nil, appliedDate: "08-Mar-2020", coverLetterString: coverLetterText),
//            Application(state: .viewedByHost, hostName: "Host 6", hostRole: "Role 6", companyName: "Company 6", industry: "Industry 6", logoUrl: nil, appliedDate: "08-Mar-2020", coverLetterString: coverLetterText),
        ]
        completion(Result<[Application],Error>.success(applications))
    }
}
