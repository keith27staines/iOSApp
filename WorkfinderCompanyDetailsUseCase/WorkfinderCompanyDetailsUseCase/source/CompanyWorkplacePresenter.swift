
import UIKit
import CoreLocation
import WorkfinderCommon
import WorkfinderUI
import WorkfinderServices

protocol CompanyWorkplaceCoordinatorProtocol : CompanyMainViewCoordinatorProtocol {
    func companyWorkplacePresenterDidFinish(_ : CompanyWorkplacePresenter)
    func companyWorkplacePresenter(_ presenter: CompanyWorkplacePresenter, requestsShowLinkedInFor: Host)
    func companyWorkplacePresenter(_ presenter: CompanyWorkplacePresenter, requestsShowLinkedInFor: CompanyWorkplace)
    func companyWorkplacePresenter(_ presenter: CompanyWorkplacePresenter, requestedShowDuedilFor: CompanyWorkplace)
    func companyWorkplacePresenter(_ presenter: CompanyWorkplacePresenter, requestOpenLink link: URL)
    func applyTo(companyWorkplace: CompanyWorkplace, hostLocationAssociation: HostLocationAssociationJson)
}

protocol CompanyWorkplacePresenterProtocol: class {
    var mainViewPresenter: CompanyMainViewPresenter { get }
    func onTapBack()
    func onTapApply()
    func onViewDidLoad(_ view: CompanyWorkplaceViewProtocol)
}

class CompanyWorkplacePresenter : NSObject, CompanyWorkplacePresenterProtocol {
    
    weak var log: F4SAnalyticsAndDebugging?
    weak var coordinator: CompanyWorkplaceCoordinatorProtocol?
    weak var view: CompanyWorkplaceViewProtocol?
    let associationsProvider: HostLocationAssociationsServiceProtocol
    var mainViewPresenter: CompanyMainViewPresenter
    var associations: HostLocationAssociationListJson?
    var selectedPersonIndexDidChange: ((Int?) -> ())?
    var userLocation: CLLocation?
    
    var companyPostcode: String? {
        didSet { view?.refresh() }
    }

    var companyWorkplace: CompanyWorkplace {
        didSet {
            view?.refresh()
        }
    }
    
    var companyLocation: CLLocation {
        let pin = companyWorkplace.pinJson
        return CLLocation(latitude: pin.lat, longitude: pin.lon)
    }
    
    var distanceFromUserToCompany: String? {
        guard let userLocation = userLocation else { return nil }
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumIntegerDigits = 1
        let distance = NSNumber(value: userLocation.distance(from: companyLocation) / 1000.0)
        guard let formattedDistance = numberFormatter.string(from: distance) else { return nil }
        return "Distance from you: \(formattedDistance) km"
    }
    
    enum InitiateApplicationResult {
        case deniedAlreadyApplied
        case allowed
        
        var deniedReason: (title:String, message: String, buttonTitle: String)? {
            switch self {
            case .deniedAlreadyApplied:
                return ("Already applied","You have already applied to this company", "Cancel")
            case .allowed:
                return nil
            }
        }
    }
    
    func onViewDidLoad(_ view: CompanyWorkplaceViewProtocol) {
        view.presenter = self
        self.view = view
        mainViewPresenter.hostsSectionPresenter.onViewDidLoad(view)
        beginLoadHosts()
    }
    
    func onTapBack() {
        coordinator?.companyWorkplacePresenterDidFinish(self)
    }
    
    func onTapApply() {
        guard let host = mainViewPresenter.hostsSectionPresenter.selectedAssociation else { return }
        coordinator?.applyTo(companyWorkplace: companyWorkplace, hostLocationAssociation: host)
    }
    
    init(coordinator: CompanyWorkplaceCoordinatorProtocol,
         companyWorkplace: CompanyWorkplace,
         associationsProvider: HostLocationAssociationsServiceProtocol,
         log: F4SAnalyticsAndDebugging?) {
        self.associationsProvider = associationsProvider
        self.companyWorkplace = companyWorkplace
        self.coordinator = coordinator
        self.log = log
        self.mainViewPresenter = CompanyMainViewPresenter(companyWorkplace: companyWorkplace, coordinator: coordinator)
        super.init()
    }
    
    var applyButtonState: (String, Bool, UIColor) {
        if true   {
            return ("Apply", true, WorkfinderColors.primaryGreen)
        } else {
            return ("Choose a host", false, UIColor.lightGray)
        }
    }
        
    func onDidUpdate() {
        view?.refresh()
    }
    
    func didTapDone() {
        coordinator?.companyWorkplacePresenterDidFinish(self)
    }
    
    func didTapLinkedIn(for host: Host) {
        coordinator?.companyWorkplacePresenter(self, requestsShowLinkedInFor: host)
    }
    
    func didTapLinkedIn(for companyWorkplace: CompanyWorkplace) {
        coordinator?.companyWorkplacePresenter(self, requestsShowLinkedInFor: companyWorkplace)
    }
    
    func didTapDuedil(for companyWorkplace: CompanyWorkplace) {
        log?.track(event: .companyDetailsDataDuedilLinkTap, properties: nil)
        coordinator?.companyWorkplacePresenter(self, requestedShowDuedilFor: companyWorkplace)
    }
    
    func didTapApply(completion: @escaping (InitiateApplicationResult) -> Void) {
        applyIfStateAllows(completion: completion)
    }
    
    func didTapLink(url: URL) {
        coordinator?.companyWorkplacePresenter(self, requestOpenLink: url)
    }
    
    func applyIfStateAllows(completion: @escaping (InitiateApplicationResult) -> Void) {
        view?.showLoadingIndicator()
        view?.hideLoadingIndicator(self)
        completion(.allowed)
    }
    
    func beginLoadHosts() {
        view?.showLoadingIndicator()
        let locationUuid = companyWorkplace.pinJson.workplaceUuid
        associationsProvider.fetchAssociations(for: locationUuid) { [weak self] (result) in
            guard let self = self else { return }
            self.view?.hideLoadingIndicator(self)
            switch result {
            case .failure(_):
                break
            case .success(let associationsJson):
                self.associations = associationsJson
                self.mainViewPresenter.hostsSectionPresenter.onHostsDidLoad(associationsJson.results)
                self.onDidUpdate()
            }
        }
    }
}
