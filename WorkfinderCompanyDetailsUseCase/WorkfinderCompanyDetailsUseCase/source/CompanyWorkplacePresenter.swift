
import UIKit
import CoreLocation
import WorkfinderCommon

let workfinderGreen = UIColor(red: 57, green: 167, blue: 82)

protocol CompanyWorkplaceCoordinatorProtocol : class {
    func companyWorkplacePresenterDidFinish(_ : CompanyWorkplacePresenter)
    func companyWorkplacePresenter(_ presenter: CompanyWorkplacePresenter, requestsShowLinkedInFor: F4SHost)
    func companyWorkplacePresenter(_ presenter: CompanyWorkplacePresenter, requestsShowLinkedInFor: CompanyWorkplace)
    func companyWorkplacePresenter(_ presenter: CompanyWorkplacePresenter, requestedShowDuedilFor: CompanyWorkplace)
    func companyWorkplacePresenter(_ presenter: CompanyWorkplacePresenter, requestOpenLink link: URL)
}

protocol CompanyWorkplacePresenterProtocol: class {
    var mainViewPresenter: CompanyMainViewPresenter { get }
    var isShowingMap: Bool { get set }
    func onTapBack()
    func onTapApply()
}

class CompanyWorkplacePresenter : NSObject, CompanyWorkplacePresenterProtocol {
    
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
    
    func onTapBack() {
    }
    
    func onTapApply() {
    }
    
    var isShowingMap: Bool = false {
        didSet {
            view?.companyWorkplacePresenter(self, showMap: isShowingMap)
        }
    }
    
    var companyPostcode: String? {
        didSet { view?.companyWorkplacePresenterDidRefresh(self) }
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
    weak var coordinator: CompanyWorkplaceCoordinatorProtocol?
    weak var view: CompanyWorkplaceViewProtocol?

    var companyWorkplace: CompanyWorkplace {
        didSet {
            view?.companyWorkplacePresenterDidRefresh(self)
        }
    }
    let companyService: F4SCompanyServiceProtocol
    
    weak var log: F4SAnalyticsAndDebugging?
    
    init(coordinator: CompanyWorkplaceCoordinatorProtocol,
         companyWorkplace: CompanyWorkplace,
         companyService: F4SCompanyServiceProtocol,
         log: F4SAnalyticsAndDebugging?) {
        self.companyService = companyService
        self.companyWorkplace = companyWorkplace
        self.coordinator = coordinator
        self.log = log
        self.mainViewPresenter = CompanyMainViewPresenter(companyWorkplace: companyWorkplace)
        super.init()
    }
    
    func attachView(view: CompanyWorkplaceViewProtocol) {
        self.view = view
        view.presenter = self
    }
    
    var mainViewPresenter: CompanyMainViewPresenter
    
    func startLoad() {
        loadCompany()
        companyWorkplace.getPostcode { [weak self] postcode in
            guard let self = self else { return }
            self.onDidUpdate()
        }
    }
    
    var applyButtonState: (String, Bool, UIColor) {
        if true   {
            return ("Apply", true, workfinderGreen)
        } else {
            return ("Choose a host", false, UIColor.lightGray)
        }
    }
        
    func onDidUpdate() {
        view?.companyWorkplacePresenterDidRefresh(self)
    }
    
    func didTapDone() {
        coordinator?.companyWorkplacePresenterDidFinish(self)
    }
    
    func didTapLinkedIn(for host: F4SHost) {
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
        view?.companyWorkplacePresenterDidBeginNetworkTask(self)
        view?.companyWorkplacePresenterDidEndLoadingTask(self)
        completion(.allowed)
    }

    func loadCompany() {
        view?.companyWorkplacePresenterDidBeginNetworkTask(self)
        let companyUuid = companyWorkplace.companyJson.uuid!
        companyService.getCompany(uuid: companyUuid) { (result) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.view?.companyWorkplacePresenterDidEndLoadingTask(self)
                switch result {
                case .error(let error):
                    if error.retry {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+5, execute: {
                            self.loadCompany()
                        })
                    }
                case .success(let json):
                    self.onDidUpdate()
                }
            }
        }
    }
}

extension CompanyWorkplace {
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
