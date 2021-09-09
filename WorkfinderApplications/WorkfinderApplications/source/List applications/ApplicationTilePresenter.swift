import WorkfinderCommon

class ApplicationTilePresenter {
    private let application: Application
    var companyName: String { application.companyName }
    var roleName: String { application.roleName }
    var hostInformation: String { application.hostName + " | " + application.hostRole }
    var industry: String { application.industry ?? "" }
    var state: ApplicationState { application.state }
    var logoUrl: String? { application.logoUrl }
    var appliedDateString: String { "Application made on \(_formattedDate)" }
    
    private var _appliedDate: Date? { Date.dateFromRfc3339(string: application.appliedDate) }
    
    private var _formattedDate: String {
        guard let date = _appliedDate else { return "" }
        let df = DateFormatter()
        df.timeStyle = .none
        df.dateFormat = "dd MMM yyyy"
        return df.string(from: date)
    }
    
    init(application: Application) {
        self.application = application
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
