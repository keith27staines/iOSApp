
import UIKit
import CoreLocation
import WorkfinderCommon
import WorkfinderServices

let workfinderGreen = UIColor(red: 57, green: 167, blue: 82)

protocol CompanyWorkplaceCoordinatorProtocol : class {
    func companyWorkplacePresenterDidFinish(_ : CompanyWorkplacePresenter)
    func companyWorkplacePresenter(_ presenter: CompanyWorkplacePresenter, requestsShowLinkedInFor: Host)
    func companyWorkplacePresenter(_ presenter: CompanyWorkplacePresenter, requestsShowLinkedInFor: CompanyWorkplace)
    func companyWorkplacePresenter(_ presenter: CompanyWorkplacePresenter, requestedShowDuedilFor: CompanyWorkplace)
    func companyWorkplacePresenter(_ presenter: CompanyWorkplacePresenter, requestOpenLink link: URL)
}

protocol CompanyWorkplacePresenterProtocol: class {
    var mainViewPresenter: CompanyMainViewPresenter { get }
    var isShowingMap: Bool { get set }
    func onTapBack()
    func onTapApply()
    func onViewDidLoad(_ view: CompanyWorkplaceViewProtocol)
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
    let hostsProvider: HostsProviderProtocol
    
    weak var log: F4SAnalyticsAndDebugging?
    
    init(coordinator: CompanyWorkplaceCoordinatorProtocol,
         companyWorkplace: CompanyWorkplace,
         hostsProvider: HostsProviderProtocol,
         log: F4SAnalyticsAndDebugging?) {
        self.hostsProvider = hostsProvider
        self.companyWorkplace = companyWorkplace
        self.coordinator = coordinator
        self.log = log
        self.mainViewPresenter = CompanyMainViewPresenter(companyWorkplace: companyWorkplace)
        super.init()
    }
    
    var mainViewPresenter: CompanyMainViewPresenter
    
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
        view?.companyWorkplacePresenterDidBeginNetworkTask(self)
        view?.companyWorkplacePresenterDidEndLoadingTask(self)
        completion(.allowed)
    }

    func beginLoadHosts() {
        view?.companyWorkplacePresenterDidBeginNetworkTask(self)
        let locationUuid = companyWorkplace.pinJson.workplaceUuid
        hostsProvider.fetchHosts(locationUuid: locationUuid) { [weak self] (result) in
            guard let self = self else { return }
            self.view?.companyWorkplacePresenterDidEndLoadingTask(self)
            switch result {
            case .failure(_):
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+5, execute: {
                    self.beginLoadHosts()
                })
            case .success(let hosts):
                self.mainViewPresenter.hostsSectionPresenter.onHostsDidLoad(hosts)
                self.onDidUpdate()
            }
        }
    }
}
