
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
        self.appliedDateString = application.appliedDate
        self.industry = application.industry
        self.state = application.state
        self.logoUrl = application.logoUrl
    }
}
