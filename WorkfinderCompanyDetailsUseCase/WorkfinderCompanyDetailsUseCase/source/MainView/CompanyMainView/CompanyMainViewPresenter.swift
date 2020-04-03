import WorkfinderCommon
import UIKit

protocol CompanyMainViewCoordinatorProtocol: class {
    func applyTo(companyWorkplace: CompanyWorkplace, host: Host)
}

protocol CompanyMainViewPresenterProtocol: class {
    var view: CompanyMainViewProtocol? { get set }
    var companyName: String { get }
    var companyLocation: LatLon { get }
    var isHostSelected: Bool { get }
    var headerViewPresenter: CompanyHeaderViewPresenterProtocol { get }
    var summarySectionPresenter: CompanySummarySectionPresenterProtocol { get }
    var dataSectionPresenter: CompanyDataSectionPresenterProtocol { get }
    var hostsSectionPresenter: CompanyHostsSectionPresenterProtocol { get }
    func onDidTapApply()
}

class CompanyMainViewPresenter: CompanyMainViewPresenterProtocol {
    weak var coordinator: CompanyMainViewCoordinatorProtocol?
    weak var view: CompanyMainViewProtocol?
    var companyWorkplace: CompanyWorkplace
    var pin: PinJson { self.companyWorkplace.pinJson }
    var companyName: String { return self.companyWorkplace.companyJson.name ?? "unnamed company" }
    var companyLocation: LatLon {
        return LatLon(latitude: CGFloat(pin.lat), longitude: CGFloat(pin.lon))
    }
    
    var selectedHost: Host? { return hostsSectionPresenter.selectedHost }
    var isHostSelected: Bool { return hostsSectionPresenter.isHostSelected }

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
        return CompanyHostsSectionPresenter()
    }()

    init(companyWorkplace: CompanyWorkplace, coordinator: CompanyMainViewCoordinatorProtocol) {
        self.coordinator = coordinator
        self.companyWorkplace = companyWorkplace
    }
    
    func onDidTapApply() {
        guard let host = selectedHost else { return }
        coordinator?.applyTo(companyWorkplace: companyWorkplace, host: host)
    }
}

