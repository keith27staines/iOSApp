
import UIKit
import WorkfinderCommon
import WorkfinderUI

protocol CompanyMainViewCoordinatorProtocol: class {
    func onDidTapDuedil()
    func onDidTapLinkedin(association: HostLocationAssociationJson)
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
    var log: F4SAnalyticsAndDebugging?
    weak var coordinator: CompanyMainViewCoordinatorProtocol?
    weak var view: CompanyMainViewProtocol?
    var companyWorkplace: CompanyWorkplace
    var companyName: String { return self.companyWorkplace.companyJson.name ?? "unnamed company" }
    var pin: PinJson { self.companyWorkplace.pinJson }
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
        let presenter = CompanyDataSectionPresenter(companyWorkplace: self.companyWorkplace)
        presenter.onDidTapDuedil = {
            self.coordinator?.onDidTapDuedil()
        }
        return presenter
    }()
    
    lazy var hostsSectionPresenter: CompanyHostsSectionPresenterProtocol = {
        let companyHostsPresenter = CompanyHostsSectionPresenter()
        companyHostsPresenter.tappedLinkedin = { association in
            self.coordinator?.onDidTapLinkedin(association: association)
        }
        return companyHostsPresenter
    }()

    init(companyWorkplace: CompanyWorkplace,
         coordinator: CompanyMainViewCoordinatorProtocol,
         log: F4SAnalyticsAndDebugging?) {
        self.log = log
        self.coordinator = coordinator
        self.companyWorkplace = companyWorkplace
    }
    
    func onDidTapApply() {
        guard let association = selectedAssociation else { return }
        let hostRowIndex = hostsSectionPresenter.selectedHostRow  ?? 0
        let host = hostsSectionPresenter.selectedAssociation?.host.uuid ?? ""
        let company = companyWorkplace.companyJson.uuid ?? ""
        let event = TrackEventFactory.makeApplyStart(
            hostRowIndex: hostRowIndex,
            host: host,
            company: company)
        
        log?.track(event: event)
        coordinator?.applyTo(companyWorkplace: companyWorkplace, hostLocationAssociation: association)
    }
}

