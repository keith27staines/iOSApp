
import UIKit
import CoreLocation
import WorkfinderCommon

let workfinderGreen = UIColor(red: 57, green: 167, blue: 82)

protocol CompanyViewModelCoordinatingDelegate : class {
    func companyViewModelDidComplete(_ viewModel: CompanyViewModel)
    func companyViewModel(_ viewModel: CompanyViewModel, applyTo: CompanyViewData, continueFrom: F4STimelinePlacement?)
    func companyViewModel(_ viewModel: CompanyViewModel, requestsShowLinkedIn person: F4SHost)
    func companyViewModel(_ viewModel: CompanyViewModel, requestsShowLinkedIn company: CompanyViewData)
    func companyViewModel(_ viewModel: CompanyViewModel, requestedShowDuedil company: CompanyViewData)
    func companyViewModel(_ viewModel: CompanyViewModel, showShare company: CompanyViewData)
    func companyViewModel(_ viewModel: CompanyViewModel, requestOpenLink link: URL)
}

protocol CompanyViewModelDelegate : class {
    func companyViewModelDidRefresh(_ viewModel: CompanyViewModel)
    func companyViewModelDidBeginNetworkTask(_ viewModel: CompanyViewModel)
    func companyViewModelDidCompleteLoadingTask(_ viewModel: CompanyViewModel)
    func companyViewModelNetworkTaskDidFail(_ viewModel: CompanyViewModel, error: F4SNetworkError, retry: (() -> Void)?)
    func companyViewModel(_ viewModel: CompanyViewModel, showMap: Bool)
}

class CompanyViewModel : NSObject {
    
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
            viewModelDelegate?.companyViewModel(self, showMap: isShowingMap)
        }
    }
    
    var companyPostcode: String? {
        didSet { viewModelDelegate?.companyViewModelDidRefresh(self) }
    }
    
    var userLocation: CLLocation?
    
    var distanceFromUserToCompany: String? {
        guard let userLocation = userLocation else { return nil }
        let companyLocation = CLLocation(latitude: company.latitude, longitude: company.longitude)
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumIntegerDigits = 1
        let distance = NSNumber(value: userLocation.distance(from: companyLocation) / 1000.0)
        guard let formattedDistance = numberFormatter.string(from: distance) else { return nil }
        return "Distance from you: \(formattedDistance) km"
    }
    
    var selectedPersonIndexDidChange: ((Int?) -> ())?
    weak var coordinatingDelegate: CompanyViewModelCoordinatingDelegate?
    weak var viewModelDelegate: CompanyViewModelDelegate?
    let favouritingModel: CompanyFavouritesModel
    var addToshortlistService: CompanyFavouritingServiceProtocol?
    private (set) var company: Company
    var companyViewData: CompanyViewData
    var hosts: [F4SHost] = [] {
        didSet {
            textModel = TextModel(hosts: hosts)
        }
    }
    var textModel = TextModel(hosts: [])
    let companyService: F4SCompanyServiceProtocol
    let companyDocumentsModel: F4SCompanyDocumentsModelProtocol
    let canApplyLogic: AllowedToApplyLogicProtocol
    
    var companyJson: F4SCompanyJson? = nil {
        didSet {
            companyViewData.duedilUrl = companyJson?.duedilUrlString
            companyViewData.linkedinUrl = companyJson?.linkedInUrlString
            viewModelDelegate?.companyViewModelDidRefresh(self)
        }
    }
    
    lazy var dataSectionRows: CompanyDataSectionRows = {
        return CompanyDataSectionRows(viewModel: self, companyDocumentsModel: self.companyDocumentsModel)
    }()
    
    weak var log: F4SAnalyticsAndDebugging?
    
    init(coordinatingDelegate: CompanyViewModelCoordinatingDelegate,
         viewModelDelegate: CompanyViewModelDelegate? = nil,
         company: Company,
         companyService: F4SCompanyServiceProtocol,
         favouritingModel: CompanyFavouritesModel,
         allowedToApplyLogic: AllowedToApplyLogicProtocol,
         companyDocumentsModel: F4SCompanyDocumentsModelProtocol,
         log: F4SAnalyticsAndDebugging?) {
        self.companyService = companyService
        self.company = company
        self.companyViewData = CompanyViewData(company: company)
        self.coordinatingDelegate = coordinatingDelegate
        self.viewModelDelegate = viewModelDelegate
        self.favouritingModel = favouritingModel
        self.companyViewData.isFavourited = self.favouritingModel.isFavourite(company: company)
        self.canApplyLogic = allowedToApplyLogic
        self.companyDocumentsModel = companyDocumentsModel
        self.log = log
        super.init()
    }
    
    func startLoad() {
        loadCompany()
        loadDocuments()
        company.getPostcode { [weak self] postcode in
            guard let self = self else { return }
            self.companyViewData.postcode = postcode
            self.onDidUpdate()
        }
        checkUserCanApply { [weak self] (result) in
            guard let self = self else { return }
            self.userCanApply = result == .allowed ? true : false
            self.onDidUpdate()
        }
    }
    
    var applyButtonState: (String, Bool, UIColor) {
        switch userCanApply {
        case true:
            if let _ = selectedHost {
                return ("Apply", true, workfinderGreen)
            } else {
                return ("Choose a host", false, UIColor.lightGray)
            }
        case false:
            return ("Already applied", false, UIColor.lightGray)
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
            viewModelDelegate?.companyViewModelDidRefresh(self)
        }
        viewModelDelegate?.companyViewModelDidRefresh(self)
    }
    
    private func updateHost(from updatedHost: F4SHost) {
        guard let index = (hosts.firstIndex { (host) -> Bool in
            host.uuid == updatedHost.uuid
        }) else { return }
        hosts[index] = updatedHost
    }
    
    func onDidUpdate() {
        dataSectionRows = CompanyDataSectionRows(viewModel: self, companyDocumentsModel: companyDocumentsModel)
        viewModelDelegate?.companyViewModelDidRefresh(self)
    }
    
    func didTapDone() {
        coordinatingDelegate?.companyViewModelDidComplete(self)
    }
    
    var isFavourited: Bool {
        return companyViewData.isFavourited
    }
    
    func toggleFavourited() {
        favouritingModel.delegate = self
        switch companyViewData.isFavourited {
        case true:
            favouritingModel.unfavourite(company: company)
        case false:
            favouritingModel.favourite(company: company)
        }
    }
    
    func showShare() {
        coordinatingDelegate?.companyViewModel(self, showShare: companyViewData)
    }
    
    func didTapLinkedIn(for host: F4SHost) {
        coordinatingDelegate?.companyViewModel(self, requestsShowLinkedIn: host)
    }
    
    func didTapLinkedIn(for company: CompanyViewData) {
        coordinatingDelegate?.companyViewModel(self, requestsShowLinkedIn: company)
    }
    
    func didTapDuedil(for company: CompanyViewData) {
        log?.track(event: .companyDetailsDataDuedilLinkTap, properties: nil)
        coordinatingDelegate?.companyViewModel(self, requestedShowDuedil: company)
    }
    
    func didTapApply(completion: @escaping (InitiateApplicationResult) -> Void) {
        applyIfStateAllows(completion: completion)
    }
    
    func didTapLink(url: URL) {
        coordinatingDelegate?.companyViewModel(self, requestOpenLink: url)
    }
    
    var userCanApply: Bool = false
    
    func checkUserCanApply(completion: @escaping (InitiateApplicationResult) -> Void) {
        viewModelDelegate?.companyViewModelDidBeginNetworkTask(self)
        canApplyLogic.checkUserCanApply(user: "", to: company.uuid) { (networkResult) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                switch networkResult {
                case .error(let error):
                    strongSelf.viewModelDelegate?.companyViewModelNetworkTaskDidFail(strongSelf, error: error, retry: {
                        strongSelf.checkUserCanApply(completion: completion)
                    })
                case .success(true):
                    strongSelf.viewModelDelegate?.companyViewModelDidCompleteLoadingTask(strongSelf)
                    completion(.allowed)
                case .success(false):
                    strongSelf.viewModelDelegate?.companyViewModelDidCompleteLoadingTask(strongSelf)
                    completion(.deniedAlreadyApplied)
                }
            }
        }
    }
    
    func applyIfStateAllows(completion: @escaping (InitiateApplicationResult) -> Void) {
        viewModelDelegate?.companyViewModelDidBeginNetworkTask(self)
        canApplyLogic.checkUserCanApply(user: "", to: company.uuid) { [weak self] (networkResult) in
            guard let strongSelf = self else { return }
            switch networkResult {
            case .error(let error):
                strongSelf.viewModelDelegate?.companyViewModelNetworkTaskDidFail(strongSelf, error: error, retry: {
                    strongSelf.applyIfStateAllows(completion: completion)
                })
            case .success(true):
                strongSelf.viewModelDelegate?.companyViewModelDidCompleteLoadingTask(strongSelf)
                strongSelf.coordinatingDelegate?.companyViewModel(strongSelf, applyTo: strongSelf.companyViewData, continueFrom: nil)
                completion(.allowed)
            case .success(false):
                strongSelf.viewModelDelegate?.companyViewModelDidCompleteLoadingTask(strongSelf)
                completion(.deniedAlreadyApplied)
            }
        }
    }

    func loadCompany() {
        viewModelDelegate?.companyViewModelDidBeginNetworkTask(self)
        companyService.getCompany(uuid: company.uuid) { (result) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.viewModelDelegate?.companyViewModelDidCompleteLoadingTask(self)
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
    
    func loadDocuments() {
        viewModelDelegate?.companyViewModelDidBeginNetworkTask(self)
        companyDocumentsModel.getDocuments(age:0, completion: {  (result) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.viewModelDelegate?.companyViewModelDidCompleteLoadingTask(self)
                switch result {
                case .error(let error):
                    if error.retry {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+5, execute: {
                            self.loadDocuments()
                        })
                    }
                case .success(_):
                    self.onDidUpdate()
                }
            }
        })
    }
}

extension CompanyViewModel : CompanyFavouritesModelDelegate {
    
    func companyFavouritesModelDidUpate(_ model: CompanyFavouritesModel, company: Company, isFavourite: Bool) {
        companyViewData.isFavourited = isFavourite
        viewModelDelegate?.companyViewModelDidCompleteLoadingTask(self)
    }
    
    func companyFavouritesModelFailedUpdate(
        _ model: CompanyFavouritesModel,
        company: Company,
        error: F4SNetworkError, retry: (()->Void)? = nil) {
        viewModelDelegate?.companyViewModelNetworkTaskDidFail(self, error: error, retry: retry)
    }
}

private extension Company {
    func getPostcode( completion: @escaping (String?) -> Void ) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            completion(placemarks?.first?.postalCode)
        }
    }
}
