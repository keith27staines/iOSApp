
import UIKit
import CoreLocation
import WorkfinderCommon
import WorkfinderUI
import WorkfinderCoordinators
import WorkfinderServices

protocol CompanyDetailsPresenterProtocol: class {
    var view: CompanyDetailsViewProtocol? { get set }
    var selectedHost: HostJson? { get }
    var mainViewPresenter: CompanyMainViewPresenter { get }
    func onTapBack()
    func onTapApply()
    func onViewDidLoad(_ view: CompanyDetailsViewProtocol)
}

class WorkplacePresenter : NSObject, CompanyDetailsPresenterProtocol {

    weak var log: F4SAnalyticsAndDebugging?
    weak var coordinator: CompanyDetailsCoordinator?
    weak var view: CompanyDetailsViewProtocol?
    let associationsService: AssociationsServiceProtocol
    var associations: HostAssociationListJson?
    var selectedPersonIndexDidChange: ((Int?) -> ())?
    let recommendedAssociationUuid: F4SUUID?
    
    var mainViewPresenter: CompanyMainViewPresenter
    
    var userLocation: CLLocation? {
        didSet {
            mainViewPresenter.headerViewPresenter.distanceFromCompany = self.distanceFromUserToCompany ?? "unknown distance from you"
        }
    }
    
    var selectedHost: HostJson? { mainViewPresenter.hostsSectionPresenter.selectedAssociation?.host }
    
    var companyPostcode: String? {
        didSet { view?.refresh() }
    }

    var companyAndPin: CompanyAndPin {
        didSet {
            view?.refresh()
        }
    }
    
    var companyLocation: CLLocation {
        let pin = companyAndPin.locationPin
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
        coordinator?.applyTo(workplace: companyAndPin, association: host)
    }
    
    init(coordinator: CompanyDetailsCoordinator,
         workplace: CompanyAndPin,
         recommendedAssociationUuid: F4SUUID?,
         associationsService: AssociationsServiceProtocol,
         log: F4SAnalyticsAndDebugging?,
         appSource: AppSource
    ) {
        self.associationsService = associationsService
        self.companyAndPin = workplace
        self.recommendedAssociationUuid = recommendedAssociationUuid
        self.coordinator = coordinator
        self.log = log
        self.mainViewPresenter = CompanyMainViewPresenter(
            workplace: workplace,
            coordinator: coordinator,
            log: log,
            appSource: appSource
        )
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
        let locationUuid = companyAndPin.locationPin.locationUuid
        associationsService.fetchAssociations(for: locationUuid) { [weak self] (result) in
            guard let self = self else { return }
            self.view?.hideLoadingIndicator(self)
            switch result {
            case .failure(let error):
                self.view?.showNetworkError(error, retry: self.beginLoadHosts)
            case .success(let unfilteredAssociationsJson):
                var filteredAssociations = unfilteredAssociationsJson
                if let recommendedAssociationUuid = self.recommendedAssociationUuid {
                    if let recommendedAssociation = (unfilteredAssociationsJson.results.first { (association) -> Bool in
                        association.uuid == recommendedAssociationUuid
                    }) {
                        filteredAssociations.results = [recommendedAssociation]
                        filteredAssociations.count = 1
                        filteredAssociations.next = nil
                        filteredAssociations.previous = nil
                    }
                }
                self.associations = filteredAssociations
                self.mainViewPresenter.hostsSectionPresenter.onHostsDidLoad(filteredAssociations.results)
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
