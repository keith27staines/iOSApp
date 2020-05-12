import Foundation

class ApplicationsModel {
    class Application {
        let companyName: String
        let hostInformation: String
        let appliedDateString = "15-Mar-2020"
        let industry = "Aeronautical engineering"
        init(companyName: String, hostName: String) {
            self.companyName = companyName
            self.hostInformation = hostName
        }
    }
    
    private let applications = [
        Application(companyName: "Company 1", hostName: "Host 1 | role 1"),
        Application(companyName: "Company 2", hostName: "Host 2 | role 2"),
        Application(companyName: "Company 3", hostName: "Host 3 | role 3")
    ]
    
    let numberOfSections: Int = 1
    
    func numberOfRows(section: Int) -> Int {
        return applications.count
    }
    
    func applicationForIndexPath(_ indexPath: IndexPath) -> Application {
        return applications[indexPath.row]
    }
}
