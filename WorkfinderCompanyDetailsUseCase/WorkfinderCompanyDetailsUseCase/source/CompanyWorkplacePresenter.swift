
import UIKit
import CoreLocation
import WorkfinderCommon
import WorkfinderUI
import WorkfinderCoordinators
import WorkfinderServices

public protocol CompanyCoordinatorFactoryProtocol {
    
    func buildCoordinator(
        parent: CompanyCoordinatorParentProtocol,
        navigationRouter: NavigationRoutingProtocol,
        workplace: Workplace,
        inject: CoreInjectionProtocol,
        applicationFinished: @escaping ((PreferredDestination) -> Void)
    ) -> CoreInjectionNavigationCoordinatorProtocol
}

protocol CompanyDetailsCoordinatorProtocol: CoreInjectionNavigationCoordinatorProtocol {
    var originScreen: ScreenName { get set }
    func companyDetailsPresenterDidFinish(_ presenter: CompanyDetailsPresenterProtocol)
    func companyDetailsPresenter(_ presenter: CompanyDetailsPresenterProtocol, requestedShowDuedilFor: Workplace)
    func companyDetailsPresenter(_ presenter: CompanyDetailsPresenterProtocol, requestOpenLink link: String)
    func applyTo(workplace: Workplace, hostLocationAssociation: HostAssociationJson)
    func onDidTapLinkedin(association: HostAssociationJson)
}

protocol CompanyDetailsPresenterProtocol: class {
    var selectedHost: Host? { get }
    var mainViewPresenter: CompanyMainViewPresenter { get }
    func onTapBack()
    func onTapApply()
    func onViewDidLoad(_ view: CompanyDetailsViewProtocol)
}

class WorkplacePresenter : NSObject, CompanyDetailsPresenterProtocol {

    weak var log: F4SAnalyticsAndDebugging?
    weak var coordinator: CompanyDetailsCoordinator?
    weak var view: CompanyDetailsViewProtocol?
    let associationsProvider: AssociationsServiceProtocol
    var mainViewPresenter: CompanyMainViewPresenter
    var associations: HostAssociationListJson?
    var selectedPersonIndexDidChange: ((Int?) -> ())?
    
    var userLocation: CLLocation? {
        didSet {
            mainViewPresenter.headerViewPresenter.distanceFromCompany = self.distanceFromUserToCompany ?? "unknown distance from you"
        }
    }
    
    var selectedHost: Host? { mainViewPresenter.hostsSectionPresenter.selectedAssociation?.host }
    
    var companyPostcode: String? {
        didSet { view?.refresh() }
    }

    var workplace: Workplace {
        didSet {
            view?.refresh()
        }
    }
    
    var companyLocation: CLLocation {
        let pin = workplace.pinJson
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
    
    lazy var locManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        return locationManager
    }()
    
    func onViewDidLoad(_ view: CompanyDetailsViewProtocol) {
        view.presenter = self
        self.view = view
        locManager.requestWhenInUseAuthorization()
        mainViewPresenter.hostsSectionPresenter.onViewDidLoad(view)
        beginLoadHosts()
    }
    
    func onTapBack() {
        coordinator?.companyDetailsPresenterDidFinish(self)
    }
    
    func onTapApply() {
        guard let host = mainViewPresenter.hostsSectionPresenter.selectedAssociation else { return }
        coordinator?.applyTo(workplace: workplace, hostLocationAssociation: host)
    }
    
    init(coordinator: CompanyDetailsCoordinator,
         workplace: Workplace,
         associationsProvider: AssociationsServiceProtocol,
         log: F4SAnalyticsAndDebugging?) {
        self.associationsProvider = associationsProvider
        self.workplace = workplace
        self.coordinator = coordinator
        self.log = log
        self.mainViewPresenter = CompanyMainViewPresenter(workplace: workplace, coordinator: coordinator, log: log)
        super.init()
    }
    
    var applyButtonState: (String, Bool, UIColor) {
        return ("Apply", true, WorkfinderColors.primaryColor)
    }
        
    func onDidUpdate() {
        view?.refresh()
    }
    
    func didTapDone() {
        coordinator?.companyDetailsPresenterDidFinish(self)
    }
    
    func didTapApply(completion: @escaping (InitiateApplicationResult) -> Void) {
        applyIfStateAllows(completion: completion)
    }
    
    func didTapLink(urlString: String) {
        coordinator?.companyDetailsPresenter(self, requestOpenLink: urlString)
    }
    
    func applyIfStateAllows(completion: @escaping (InitiateApplicationResult) -> Void) {
        view?.showLoadingIndicator()
        view?.hideLoadingIndicator(self)
        completion(.allowed)
    }
    
    func beginLoadHosts() {
        view?.showLoadingIndicator()
        let locationUuid = workplace.pinJson.workplaceUuid
        associationsProvider.fetchAssociations(for: locationUuid) { [weak self] (result) in
            guard let self = self else { return }
            self.view?.hideLoadingIndicator(self)
            switch result {
            case .failure(let error):
                self.view?.showNetworkError(error, retry: self.beginLoadHosts)
            case .success(let associationsJson):
                self.associations = associationsJson
                self.mainViewPresenter.hostsSectionPresenter.onHostsDidLoad(associationsJson.results)
                self.onDidUpdate()
            }
        }
    }
}

extension WorkplacePresenter: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            userLocation = locManager.location
        }
    }
}
