
import UIKit
import CoreLocation
import WorkfinderCommon

protocol CompanyViewModelCoordinatingDelegate : class {
    func companyViewModelDidComplete(_ viewModel: CompanyViewModel)
    func companyViewModel(_ viewModel: CompanyViewModel, applyTo: CompanyViewData, continueFrom: F4STimelinePlacement?)
    func companyViewModel(_ viewModel: CompanyViewModel, requestsShowLinkedIn person: F4SHost)
    func companyViewModel(_ viewModel: CompanyViewModel, requestsShowLinkedIn company: CompanyViewData)
    func companyViewModel(_ viewModel: CompanyViewModel, requestedShowDuedil company: CompanyViewData)
    func companyViewModel(_ viewModel: CompanyViewModel, showShare company: CompanyViewData)
}

protocol CompanyViewModelDelegate : class {
    func companyViewModelDidRefresh(_ viewModel: CompanyViewModel)
    func companyViewModelDidBeginNetworkTask(_ viewModel: CompanyViewModel)
    func companyViewModelDidCompleteLoadingTask(_ viewModel: CompanyViewModel)
    func companyViewModelNetworkTaskDidFail(_ viewModel: CompanyViewModel, error: F4SNetworkError, retry: (() -> Void)?)
    func companyViewModel(_ viewModel: CompanyViewModel, showMap: Bool)
}

class CompanyViewModel : NSObject {
    
    enum PageIndex : Int, CaseIterable {
        case summary
        case data
        case people
        func previous() -> PageIndex? { return PageIndex(rawValue: self.rawValue - 1) }
        func next() -> PageIndex? { return PageIndex(rawValue: self.rawValue + 1) }
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
    
    var isShowingMap: Bool = false {
        didSet {
            viewModelDelegate?.companyViewModel(self, showMap: isShowingMap)
        }
    }
    
    var companyPostcode: String? {
        didSet { viewModelDelegate?.companyViewModelDidRefresh(self) }
    }
    
    var userLocation: CLLocation? {
        didSet {
            viewModelDelegate?.companyViewModelDidRefresh(self)
        }
    }
    
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
    var hosts: [F4SHost] = []
    let companyService: F4SCompanyServiceProtocol
    let companyDocumentsModel: F4SCompanyDocumentsModelProtocol
    let canApplyLogic: AllowedToApplyLogicProtocol
    private var viewControllers = [UIViewController]()
    var currentPageIndex: PageIndex = .summary
    
    var companyJson: F4SCompanyJson? = nil {
        didSet {
            companyViewData.duedilUrl = companyJson?.duedilUrlString
            companyViewData.linkedinUrl = companyJson?.linkedInUrlString
            viewModelDelegate?.companyViewModelDidRefresh(self)
        }
    }
    
    var selectedHostIndex: Int? = nil {
        didSet {
            selectedPersonIndexDidChange?(selectedHostIndex)
        }
    }
    
    var mustSelectHostToApply: Bool {
        return false
    }
    
    var selectedHost: F4SHost? {
        guard let index = self.selectedHostIndex else { return nil }
        return self.hosts[index]
    }
    
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
        viewControllers = [summaryViewController, dataViewController]
        loadCompany()
        loadDocuments()
        company.getPostcode { [weak self] postcode in
            self?.companyViewData.postcode = postcode
            self?.summaryViewController.refresh()
        }
    }
    
    func transitionDirectionForPage(_ pageIndex: PageIndex) ->  UIPageViewController.NavigationDirection? {
        if pageIndex.rawValue > currentPageIndex.rawValue { return .forward }
        if pageIndex.rawValue < currentPageIndex.rawValue { return .reverse }
        return nil
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
        coordinatingDelegate?.companyViewModel(self, requestedShowDuedil: company)
    }
    
    func didTapApply(completion: @escaping (InitiateApplicationResult) -> Void) {
        applyIfStateAllows(completion: completion)
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
                strongSelf.viewModelDelegate?.companyViewModelDidCompleteLoadingTask(strongSelf)
                completion(.deniedAlreadyApplied)
            }
        }
    }

    func loadCompany() {
        companyService.getCompany(uuid: company.uuid) { (result) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                switch result {
                case .error(let error):
                    if error.retry {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+5, execute: {
                            strongSelf.loadCompany()
                        })
                    }
                case .success(let json):
                    strongSelf.hosts = json.hosts ?? []
                    strongSelf.companyJson = json
                    strongSelf.viewModelDelegate?.companyViewModelDidRefresh(strongSelf)
                }
            }
        }
    }
    
    func loadDocuments() {
        companyDocumentsModel.getDocuments(age:0, completion: { [weak self] (result) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .error(let error):
                    if error.retry {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+5, execute: {
                            strongSelf.loadDocuments()
                        })
                    }
                case .success(_):
                    strongSelf.viewModelDelegate?.companyViewModelDidRefresh(strongSelf)
                }
            }
        })
    }
    
    private func controller(for index: PageIndex?) -> CompanySubViewController? {
        guard let index = index else { return nil }
        switch index {
        case .summary:
            return summaryViewController
        case .data:
            return dataViewController
        case .people:
            return hostsViewController
        }
    }
    
    var currentViewController: CompanySubViewController {
        return controller(for: currentPageIndex)!
    }
    
    lazy private var summaryViewController: CompanySummaryViewController = {
        return CompanySummaryViewController(viewModel: self,
                                            pageIndex: .summary,
                                            documentsModel: companyDocumentsModel)
    }()
    
    lazy private var dataViewController: CompanyDataViewController = {
        let vc = CompanyDataViewController(viewModel: self, pageIndex: .data)
        vc.log = self.log
        return vc
    }()
    
    lazy private var hostsViewController: CompanyHostsViewController = {
        let vc = CompanyHostsViewController(viewModel: self, pageIndex: .people)
        return vc
    }()
    
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

extension CompanyViewModel: UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let pageIndex = pageIndexForViewController(viewController) else { return nil }
        let indexBefore = pageIndex.previous()
        return controller(for: indexBefore)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let pageIndex = pageIndexForViewController(viewController) else { return nil }
        let indexAfter = pageIndex.next()
        return controller(for: indexAfter)
    }
    
    func pageIndexForViewController(_ controller: UIViewController) -> PageIndex? {
        guard let controller = controller as? CompanySubViewController else {
                return nil
        }
        return controller.pageIndex
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
