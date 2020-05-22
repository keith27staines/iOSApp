import WorkfinderCommon

class ApplicationTilePresenter {
    private let application: Application
    let companyName: String
    let hostInformation: String
    let appliedDateString: String
    let industry: String
    let state: ApplicationState
    let logoUrl: String?
    init(application: Application) {
        self.application = application
        self.companyName = application.companyName
        self.hostInformation = application.hostName + " | " + application.hostRole
        self.appliedDateString = datetimeStringToDate(application.appliedDate)
        self.industry = application.industry ?? ""
        self.state = application.state
        self.logoUrl = application.logoUrl
    }
}

fileprivate func datetimeStringToDate(_ datetime: String) -> String {
    let df = DateFormatter.iso8601Full
    guard let date = df.date(from: datetime) else { return "" }
    let dt2 = DateFormatter()
    dt2.dateStyle = .long
    dt2.timeStyle = .none
    return dt2.string(from: date)
}
