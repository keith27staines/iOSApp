
import UIKit
import WorkfinderCommon
import WorkfinderUI

protocol CompanyMainViewCoordinatorProtocol: class {
    func onDidTapDuedil()
    func onDidTapLinkedin(association: ExpandedAssociation)
    func applyTo(workplace: Workplace, association: ExpandedAssociation)
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
    var workplace: Workplace
    var companyName: String { return self.workplace.companyJson.name ?? "unnamed company" }
    var pin: PinJson { self.workplace.pinJson }
    var companyLocation: LatLon {
        return LatLon(latitude: CGFloat(pin.lat), longitude: CGFloat(pin.lon))
    }
    var selectedAssociation: ExpandedAssociation? { return hostsSectionPresenter.selectedAssociation }
    var isHostSelected: Bool { return hostsSectionPresenter.isAssociationSelected }
    lazy var headerViewPresenter: CompanyHeaderViewPresenterProtocol = {
        return CompanyHeaderViewPresenter(workplace: self.workplace)
    }()
    
    lazy var summarySectionPresenter: CompanySummarySectionPresenterProtocol = {
        return CompanySummarySectionPresenter(workplace: self.workplace)
    }()
    
    lazy var dataSectionPresenter: CompanyDataSectionPresenterProtocol = {
        let presenter = CompanyDataSectionPresenter(workplace: self.workplace)
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

    init(workplace: Workplace,
         coordinator: CompanyMainViewCoordinatorProtocol,
         log: F4SAnalyticsAndDebugging?) {
        self.log = log
        self.coordinator = coordinator
        self.workplace = workplace
    }
    
    func onDidTapApply() {
        guard let association = selectedAssociation else { return }
        let hostRowIndex = hostsSectionPresenter.selectedHostRow  ?? 0
        let host = hostsSectionPresenter.selectedAssociation?.host?.uuid ?? ""
        let company = workplace.companyJson.uuid ?? ""
        let event = TrackingEvent.makeApplyStart(
            hostRowIndex: hostRowIndex,
            host: host,
            company: company)
        
        log?.track(event)
        coordinator?.applyTo(workplace: workplace, association: association)
    }
}

private extension TrackingEvent {
    static func makeApplyStart(
        hostRowIndex: Int,
        host: F4SUUID,
        company: F4SUUID) -> TrackingEvent {
        TrackingEvent(
            type: .applyStart,
            additionalProperties: [
                "host_chosen_position": hostRowIndex,
                "host_id": host,
                "company_id": company
            ]
        )
    }
}

