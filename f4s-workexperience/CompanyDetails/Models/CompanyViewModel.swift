//
//  CompanyViewViewModel.swift
//  F4SPrototypes
//
//  Created by Keith Staines on 21/12/2018.
//  Copyright © 2018 Keith Staines. All rights reserved.
//

import UIKit

protocol CompanyViewModelCoordinatingDelegate : class {
    func companyViewModelDidComplete(_ viewModel: CompanyViewModel)
    func companyViewModel(_ viewModel: CompanyViewModel, applyTo: CompanyViewData)
    func companyViewModel(_ viewModel: CompanyViewModel, requestsShowLinkedIn person: PersonViewData)
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
        // TODO: enable peopple tab:  add case people
        func previous() -> PageIndex? { return PageIndex(rawValue: self.rawValue - 1) }
        func next() -> PageIndex? { return PageIndex(rawValue: self.rawValue + 1) }
    }
    
    enum InitiateApplicationResult {
        case deniedMustSelectPerson
        case deniedAlreadyApplied
        case deniedCompanyNoAcceptingApplications
        case allowed
        
        var deniedReason: (title:String, message: String, buttonTitle: String)? {
            switch self {
            case .deniedMustSelectPerson:
                return ("You must select the person to whom you wish to apply","", "Select person")
            case .deniedAlreadyApplied:
                return ("Already applied","You have already applied to this company", "Cancel")
            case .deniedCompanyNoAcceptingApplications:
                return ("This company is not accepting applications at this time","", "Cancel")
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
    
    var selectedPersonIndexDidChange: ((Int?) -> ())?
    weak var coordinatingDelegate: CompanyViewModelCoordinatingDelegate?
    weak var viewModelDelegate: CompanyViewModelDelegate?
    let favouritingModel: CompanyFavouritesModel
    lazy var placement = PlacementDBOperations.sharedInstance.getPlacementsForCurrentUserAndCompany(companyUuid: company.uuid)
    var addToshortlistService: CompanyFavouritingServiceProtocol?
    private (set) var company: Company
    private (set) var companyViewData: CompanyViewData
    let people: [PersonViewData]
    let companyService: F4SCompanyServiceProtocol
    var appliedState: AppliedState { return companyViewData.appliedState }
    private var viewControllers = [UIViewController]()
    var currentPageIndex: PageIndex = .summary
    
    lazy var companyDocumentsModel: F4SCompanyDocumentsModel = {
        return F4SCompanyDocumentsModel(companyUuid: company.uuid)
    }()
    
    var companyJson: F4SCompanyJson? = nil {
        didSet {
            companyViewData.duedilUrl = companyJson?.duedilUrlString
            viewModelDelegate?.companyViewModelDidRefresh(self)
        }
    }
    
    var selectedPersonIndex: Int? = nil {
        didSet {
            selectedPersonIndexDidChange?(selectedPersonIndex)
        }
    }
    
    var mustSelectPersonToApply: Bool {
        return people.count == 0 ? false : selectedPerson == nil
    }
    
    var selectedPerson: PersonViewData? {
        guard let index = self.selectedPersonIndex else { return nil }
        return self.people[index]
    }
    
    init(
        coordinatingDelegate: CompanyViewModelCoordinatingDelegate,
        viewModelDelegate: CompanyViewModelDelegate? = nil,
        company: Company,
        people: [PersonViewData],
        companyService: F4SCompanyServiceProtocol = F4SCompanyService(),
        favouritingModel: CompanyFavouritesModel? = nil
        ) {
        self.companyService = companyService
        self.company = company
        self.companyViewData = CompanyViewData(company: company)
        self.people = people
        self.coordinatingDelegate = coordinatingDelegate
        self.viewModelDelegate = viewModelDelegate
        self.favouritingModel = favouritingModel ?? CompanyFavouritesModel()
        self.companyViewData.isFavourited = self.favouritingModel.isFavourite(company: company)
        super.init()
        // TODO: enable peopple tab:  viewControllers = [descriptionViewController, dataViewController, peopleViewController]
        viewControllers = [summaryViewController, dataViewController]
        loadCompany()
        loadDocuments()
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
    
    func didTapLinkedIn(for person: PersonViewData) {
        coordinatingDelegate?.companyViewModel(self, requestsShowLinkedIn: person)
    }
    
    func didTapDuedil(for company: CompanyViewData) {
        coordinatingDelegate?.companyViewModel(self, requestedShowDuedil: company)
    }
    
    func didTapApply() -> InitiateApplicationResult {
        if appliedState == .applied { return .deniedAlreadyApplied }
        if mustSelectPersonToApply { return .deniedMustSelectPerson }
        if companyViewData.isRemoved { return .deniedCompanyNoAcceptingApplications }
        coordinatingDelegate?.companyViewModel(self, applyTo: companyViewData)
        return .allowed
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
                    strongSelf.companyJson = json
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
        // TODO: enable peopple tab: uncomment .people case
        // case .people:
        // return peopleViewController
        }
    }
    
    var currentViewController: CompanySubViewController {
        return controller(for: currentPageIndex)!
    }
    // TODO: enable peopple tab: Uncomment `peopleViewController` property
    // lazy private var peopleViewController: CompanyPeopleViewController = {
    //     return CompanyPeopleViewController(viewModel: self, pageIndex: .people)
    // }()
    
    lazy private var summaryViewController: CompanySummaryViewController = {
        return CompanySummaryViewController(viewModel: self, pageIndex: .summary)
    }()
    
    lazy private var dataViewController: CompanyDataViewController = {
        return CompanyDataViewController(viewModel: self, pageIndex: .data)
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
