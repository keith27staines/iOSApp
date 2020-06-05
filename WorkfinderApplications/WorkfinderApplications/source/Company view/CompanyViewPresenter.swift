
import WorkfinderCommon
import WorkfinderServices
import CoreLocation

class CompanyViewPresenter: NSObject {
    let coordinator: ApplicationsCoordinator
    let companyService: CompanyServiceProtocol
    let associationsService: HostLocationAssociationsServiceProtocol
    let application: Application
    var view: CompanyViewController?
    var companyJson: CompanyJson?
    
    var workplace: CompanyWorkplace?
    var companyName: String? { application.companyName }
    var logoUrlString: String? { application.logoUrl }
    var pin: PinJson? { self.workplace?.pinJson }
    
    lazy var locManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        return locationManager
    }()
    
    var userLocation: CLLocation? {
        didSet {
            view?.refreshFromPresenter()
        }
    }
    
    var companyLocation: LatLon {
        guard let pin = self.pin else { return LatLon(latitude: 0, longitude: 0)}
        return LatLon(latitude: CGFloat(pin.lat), longitude: CGFloat(pin.lon))
    }
    
    var companyCLLocation: CLLocation? {
        guard let pin = pin, pin.lat != 0.0 else { return nil }
        return CLLocation(latitude: pin.lat, longitude: pin.lon)
    }
    
    var distanceFromUserToCompany: String {
        let unknownDistance = "unknown distance from you"
        guard let userLocation = userLocation, let companyCLLocation = companyCLLocation
            else { return unknownDistance }
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumIntegerDigits = 1
        let distance = NSNumber(value: userLocation.distance(from: companyCLLocation) / 1000.0)
        guard let formattedDistance = numberFormatter.string(from: distance)
            else { return unknownDistance }
        return "Distance from you: \(formattedDistance) km"
    }

    func onViewDidLoad(view: CompanyViewController) {
        self.view = view
        locManager.requestWhenInUseAuthorization()
    }
    
    func loadData(completion: @escaping (Error?) -> Void) {
        guard
            let companyUuid = application.companyUuid,
            let associationUuid = application.associationUuid
        else { return }
        companyService.fetchCompany(uuid: companyUuid) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let companyJson):
                self.companyJson = companyJson
                self.associationsService.fetchAssociation(uuid: associationUuid) { (result) in
                    switch result {
                    case .success(let association):
                        self.rebuild(companyJson: companyJson, association: association)
                        completion(nil)
                    case .failure(let error):
                        completion(error)
                    }
                }
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
        completion(nil)
    }
    
    func rebuild(companyJson: CompanyJson, association: HostWorkplaceAssociationJson) {
        let location = companyJson.locations?.first(where: { (location) -> Bool in
            location.uuid == association.locationUuid
        })
        let pinJson = PinJson(
            workplaceUuid: location?.uuid ?? "",
            latitude: Double(location?.geometry?.latitude ?? 0),
            longitude: Double(location?.geometry?.longitude ?? 0))
        workplace = CompanyWorkplace(companyJson: companyJson, pinJson: pinJson)
        summarySectionPresenter = CompanySummarySectionPresenter(companyWorkplace: workplace)
        dataSectionPresenter = CompanyDataSectionPresenter(companyWorkplace: workplace)
        dataSectionPresenter.onDidTapDuedil = {
            self.coordinator.openUrl(companyJson.duedilUrlString)
        }
    }
    
    lazy var summarySectionPresenter: CompanySummarySectionPresenterProtocol = {
        return CompanySummarySectionPresenter(companyWorkplace: self.workplace)
    }()
    
    lazy var dataSectionPresenter: CompanyDataSectionPresenterProtocol = {
        return CompanyDataSectionPresenter(companyWorkplace: self.workplace)
    }()
    
    init(coordinator: ApplicationsCoordinator,
         application: Application,
         companyService: CompanyServiceProtocol,
         associationsService: HostLocationAssociationsServiceProtocol) {
        self.coordinator = coordinator
        self.application = application
        self.companyService = companyService
        self.associationsService = associationsService
    }
    
    lazy var sectionsModel: CompanyTableSectionsModel = {
        let model = CompanyTableSectionsModel()
        let sectionsList: [CompanyTableSectionType] = [
            .companySummary,
            .companyData
        ]
        for section in sectionsList {
            model.appendDescriptor(sectionType: section, isHidden: false)
        }
        return model
    }()
    
    func numberOfSections() -> Int {
        return sectionsModel.count
    }
    
    func numberOfRowsInSection(_ section: Int ) -> Int {
        let sectionModel = sectionsModel[section]
        switch sectionModel.sectionType {
        case .companySummary:
            return summarySectionPresenter.numberOfRows
        case .companyData:
            return dataSectionPresenter.numberOfRows
        case .companyHosts:
            return 0
        }
    }
    
    func cellForTable(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let rowInSection = indexPath.row
        let sectionModel = sectionsModel[indexPath.section]
        switch sectionModel.sectionType {
        case .companySummary:
            return summarySectionPresenter.cellForRow(rowInSection, in: tableView)
        case .companyData:
            return dataSectionPresenter.cellForRow(rowInSection, in: tableView)
        case .companyHosts:
            return UITableViewCell()
        }
    }
}

extension CompanyViewPresenter: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            userLocation = locManager.location
        }
    }
}
