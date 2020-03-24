import WorkfinderCommon
import UIKit

protocol CompanyMainViewPresenterProtocol: class {
    var view: CompanyMainViewProtocol? { get set }
    var companyName: String { get }
    var companyLocation: LatLon { get }
    var isHostSelected: Bool { get }
    var headerViewPresenter: CompanyHeaderViewPresenterProtocol { get }
    var summarySectionPresenter: CompanySummarySectionPresenterProtocol { get }
    var dataSectionPresenter: CompanyDataSectionPresenterProtocol { get }
    var hostsSectionPresenter: CompanyHostsSectionPresenterProtocol { get }
}

class CompanyMainViewPresenter: CompanyMainViewPresenterProtocol {
    weak var view: CompanyMainViewProtocol?
    var companyWorkplace: CompanyWorkplace
    var pin: PinJson { self.companyWorkplace.pinJson }
    var companyName: String { return self.companyWorkplace.companyJson.name ?? "unnamed company" }
    var companyLocation: LatLon { return LatLon(latitude: CGFloat(pin.lat), longitude: CGFloat(pin.lon)) }

    var isHostSelected: Bool = false

    lazy var headerViewPresenter: CompanyHeaderViewPresenterProtocol = {
        return CompanyHeaderViewPresenter(companyWorkplace: self.companyWorkplace)
    }()
    
    lazy var summarySectionPresenter: CompanySummarySectionPresenterProtocol = {
        return CompanySummarySectionPresenter(companyWorkplace: self.companyWorkplace)
    }()
    
    lazy var dataSectionPresenter: CompanyDataSectionPresenterProtocol = {
        return CompanyDataSectionPresenter(companyWorkplace: self.companyWorkplace)
    }()
    
    var hostsSectionPresenter: CompanyHostsSectionPresenterProtocol = {
        return CompanyHostsSectionPresenter(hosts: [])
    }()

    init(companyWorkplace: CompanyWorkplace) {
        self.companyWorkplace = companyWorkplace
    }
}

