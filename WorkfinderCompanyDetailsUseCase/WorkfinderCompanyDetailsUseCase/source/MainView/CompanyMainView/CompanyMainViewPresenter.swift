import WorkfinderCommon
import UIKit

protocol CompanyMainViewCoordinatorProtocol: class {
    func applyTo(companyWorkplace: CompanyWorkplace, hostLocationAssociation: HostLocationAssociationJson)
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
    
    var selectedAssociation: HostLocationAssociationJson? { return hostsSectionPresenter.selectedAssociation }
    var isHostSelected: Bool { return hostsSectionPresenter.isAssociationSelected }

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
        guard let association = selectedAssociation else { return }
        coordinator?.applyTo(companyWorkplace: companyWorkplace, hostLocationAssociation: association)
    }
}

