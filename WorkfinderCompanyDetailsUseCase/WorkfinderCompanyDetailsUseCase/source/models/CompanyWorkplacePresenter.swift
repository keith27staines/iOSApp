
import UIKit
import CoreLocation
import WorkfinderCommon

let workfinderGreen = UIColor(red: 57, green: 167, blue: 82)

protocol CompanyWorkplacePresenterCoordinatingDelegate : class {
    func companyWorkplacePresenterDidFinish(_ : CompanyWorkplacePresenter)
    func companyWorkplacePresenter(_ presenter: CompanyWorkplacePresenter, requestsShowLinkedInFor: F4SHost)
    func companyWorkplacePresenter(_ presenter: CompanyWorkplacePresenter, requestsShowLinkedInFor: CompanyWorkplace)
    func companyWorkplacePresenter(_ presenter: CompanyWorkplacePresenter, requestedShowDuedilFor: CompanyWorkplace)
    func companyWorkplacePresenter(_ presenter: CompanyWorkplacePresenter, requestOpenLink link: URL)
}

protocol CompanyWorkplacePresenterDelegate : class {
    func companyWorkplacePresenterDidRefresh(_ presenter: CompanyWorkplacePresenter)
    func companyWorkplacePresenterDidBeginNetworkTask(_ presenter: CompanyWorkplacePresenter)
    func companyWorkplacePresenterDidEndLoadingTask(_ presenter: CompanyWorkplacePresenter)
    func companyWorkplacePresenterDidFailNetworkTask(_ presenter: CompanyWorkplacePresenter, error: F4SNetworkError, retry: (() -> Void)?)
    func companyWorkplacePresenter(_ presenter: CompanyWorkplacePresenter, showMap: Bool)
}

class CompanyWorkplacePresenter : NSObject {
    
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
    
    var isShowingMap: Bool = false {
        didSet {
            presenterDelegate?.companyWorkplacePresenter(self, showMap: isShowingMap)
        }
    }
    
    var companyPostcode: String? {
        didSet { presenterDelegate?.companyWorkplacePresenterDidRefresh(self) }
    }
    
    var userLocation: CLLocation?
    
    var distanceFromUserToCompany: String? {
        guard let userLocation = userLocation else { return nil }
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumIntegerDigits = 1
        let distance = NSNumber(value: userLocation.distance(from: companyLocation) / 1000.0)
        guard let formattedDistance = numberFormatter.string(from: distance) else { return nil }
        return "Distance from you: \(formattedDistance) km"
    }
    
    var companyLocation: CLLocation {
        let pin = companyWorkplace.pinJson
        return CLLocation(latitude: pin.lat, longitude: pin.lon)
    }
    
    var selectedPersonIndexDidChange: ((Int?) -> ())?
    weak var coordinatingDelegate: CompanyWorkplacePresenterCoordinatingDelegate?
    weak var presenterDelegate: CompanyWorkplacePresenterDelegate?

    var companyWorkplace: CompanyWorkplace {
        didSet {
            presenterDelegate?.companyWorkplacePresenterDidRefresh(self)
        }
    }

    var hosts: [F4SHost] = [] {
        didSet {
            if hosts.count == 1 {
                hosts[0].isSelected = true
            }
            textModel = TextModel(hosts: hosts)
        }
    }
    var textModel = TextModel(hosts: [])
    let companyService: F4SCompanyServiceProtocol

    lazy var dataSectionRows: CompanyDataSectionRows = {
        return CompanyDataSectionRows(viewModel: self, companyDocumentsModel: self.companyDocumentsModel)
    }()
    
    weak var log: F4SAnalyticsAndDebugging?
    
    init(coordinatingDelegate: CompanyWorkplacePresenterCoordinatingDelegate,
         viewModelDelegate: CompanyWorkplacePresenterDelegate? = nil,
         companyWorkplace: CompanyWorkplace,
         companyService: F4SCompanyServiceProtocol,
         log: F4SAnalyticsAndDebugging?) {
        self.companyService = companyService
        self.companyWorkplace = companyWorkplace
        self.coordinatingDelegate = coordinatingDelegate
        self.presenterDelegate = viewModelDelegate
        self.log = log
        super.init()
    }
    
    func startLoad() {
        loadCompany()
        companyWorkplace.getPostcode { [weak self] postcode in
            guard let self = self else { return }
            self.onDidUpdate()
        }
    }
    
    var applyButtonState: (String, Bool, UIColor) {
        if let _ = selectedHost {
            return ("Apply", true, workfinderGreen)
        } else {
            return ("Choose a host", false, UIColor.lightGray)
        }
    }
    
    var selectedHost: F4SHost? {
        let host = hosts.first { (host) -> Bool in host.isSelected }
        return host
    }
    
    func updateHostSelectionState(from updatedHost: F4SHost) {
        if updatedHost.isSelected {
            for (index, host) in hosts.enumerated() {
                if host.uuid == updatedHost.uuid {
                    updateHost(from: updatedHost)
                    continue
                }
                hosts[index].isSelected = false
            }
        } else {
            updateHost(from: updatedHost)
            presenterDelegate?.companyWorkplacePresenterDidRefresh(self)
        }
        presenterDelegate?.companyWorkplacePresenterDidRefresh(self)
    }
    
    private func updateHost(from updatedHost: F4SHost) {
        guard let index = (hosts.firstIndex { (host) -> Bool in
            host.uuid == updatedHost.uuid
        }) else { return }
        hosts[index] = updatedHost
    }
    
    func onDidUpdate() {
        dataSectionRows = CompanyDataSectionRows(presenter: self)
        presenterDelegate?.companyWorkplacePresenterDidRefresh(self)
    }
    
    func didTapDone() {
        coordinatingDelegate?.companyWorkplacePresenterDidFinish(self)
    }
    
    func didTapLinkedIn(for host: F4SHost) {
        coordinatingDelegate?.companyWorkplacePresenter(self, requestsShowLinkedInFor: host)
    }
    
    func didTapLinkedIn(for companyWorkplace: CompanyWorkplace) {
        coordinatingDelegate?.companyWorkplacePresenter(self, requestsShowLinkedInFor: companyWorkplace)
    }
    
    func didTapDuedil(for companyWorkplace: CompanyWorkplace) {
        log?.track(event: .companyDetailsDataDuedilLinkTap, properties: nil)
        coordinatingDelegate?.companyWorkplacePresenter(self, requestedShowDuedilFor: companyWorkplace)
    }
    
    func didTapApply(completion: @escaping (InitiateApplicationResult) -> Void) {
        applyIfStateAllows(completion: completion)
    }
    
    func didTapLink(url: URL) {
        coordinatingDelegate?.companyWorkplacePresenter(self, requestOpenLink: url)
    }
    
    func applyIfStateAllows(completion: @escaping (InitiateApplicationResult) -> Void) {
        presenterDelegate?.companyWorkplacePresenterDidBeginNetworkTask(self)
        presenterDelegate?.companyWorkplacePresenterDidEndLoadingTask(self)
        completion(.allowed)
    }

    func loadCompany() {
        presenterDelegate?.companyWorkplacePresenterDidBeginNetworkTask(self)
        let companyUuid = companyWorkplace.companyJson.uuid
        companyService.getCompany(uuid: companyUuid) { (result) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.presenterDelegate?.companyWorkplacePresenterDidEndLoadingTask(self)
                switch result {
                case .error(let error):
                    if error.retry {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+5, execute: {
                            self.loadCompany()
                        })
                    }
                case .success(let json):
                    self.hosts = json.hosts ?? []
                    self.companyJson = json
                    self.onDidUpdate()
                }
            }
        }
    }
}

private extension CompanyWorkplace {
    func getPostcode( completion: @escaping (String?) -> Void ) {
        let latitude = pinJson.lat
        let longitude = pinJson.lon
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            completion(placemarks?.first?.postalCode)
        }
    }
}
