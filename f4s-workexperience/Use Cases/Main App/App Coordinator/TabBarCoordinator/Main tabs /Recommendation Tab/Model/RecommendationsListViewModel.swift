//
//  RecommendationsListViewModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 20/04/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

public protocol RecommendationsListViewProtocol : class {
    func showLoadingOverlay()
    func hideLoadingOverlay()
    func updateFromViewModel()
}

public protocol RecommendationsViewModelProtocol : class {
    var numberOfSections: Int { get }
    var emptyRecomendationsListText: String { get }
    var emptyRecomendationsListIsHidden: Bool { get }
    var badgeValue: String? { get }
    var isViewVisible: Bool { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func recommendationForIndexPath(_ indexPath: IndexPath) -> CompanyViewData
    func didSelectIndexPath(_ indexPath: IndexPath)
    func viewDidAppear()
    func viewDidDisappear()
    func startPolling()
}

public class RecommendationsViewModel : RecommendationsViewModelProtocol {

    public var isViewVisible: Bool = false
    public var badgeValue: String?
    public let numberOfSections: Int = 1
    public let emptyRecomendationsListText: String = NSLocalizedString("No recommendations for you yet", comment: "")
    public var emptyRecomendationsListIsHidden: Bool { return !companies.isEmpty }
    
    let model: RecommendedCompaniesListModelProtocol
    weak var view: RecommendationsListViewProtocol!
    var pollTimer: Timer?
    weak var coordinator: RecommendationsCoordinator?

    let converter = RecommendationCompanyConverter()
    var companies: [CompanyViewData] = []
    
    lazy var recommendationsRepository: RecommendedCompaniesLocalRepositoryProtocol = {
        let localStore = LocalStore()
        return RecommendedCompaniesLocalRepository(localStore: localStore)
    }()
    
    lazy var merger: RecommendedCompaniesMerger = {
        let localFetch = recommendationsRepository.loadRecommendations()
        let merger = RecommendedCompaniesMerger(fetchedFromLocalStore: localFetch)
        return merger
    }()
    
    public func viewDidAppear() {
        isViewVisible = true
        view.updateFromViewModel()
        markRecommendedCompaniesAsRead()
        processFetch(nil)
        reload(withOverlay: companies.isEmpty)
    }
    
    public func viewDidDisappear() {
        isViewVisible = false
    }
    
    func markRecommendedCompaniesAsRead() {
        let recommendations = converter.convert(companies: companies)
        recommendationsRepository.saveRecommendations(recommendations)
        merger.reset(withFetchFromLocalStore: recommendations)
    }
    
    public func reload(withOverlay: Bool = false) {
        if withOverlay { view.showLoadingOverlay() }
        model.fetch { [weak self] companyRecommendations in
            self?.processFetch(companyRecommendations)
            if withOverlay { self?.view.hideLoadingOverlay() }
        }
    }
    
    func processFetch(_ fetched: [F4SRecommendation]?) {
        let dehyphenatedFetch = fetched?.compactMap({ (recommendation) -> F4SRecommendation? in
            guard let uuid = recommendation.uuid else { return nil }
            return F4SRecommendation(companyUUID: uuid.dehyphenated, sortIndex: recommendation.index)
        })
        let mergedRecommendations = merger.merge(fetchedFromServer: dehyphenatedFetch)
        let numberAddedSinceLastReset = merger.numberAddedSinceLastReset
        badgeValue = numberAddedSinceLastReset > 0 ? String(merger.numberAddedSinceLastReset) : nil
        companies = converter.convert(recommendations: mergedRecommendations)
        view.updateFromViewModel()
    }
    
    public func recommendationForIndexPath(_ indexPath: IndexPath) -> CompanyViewData {
        return companies[indexPath.row]
    }
    
    public func didSelectIndexPath(_ indexPath: IndexPath) {
        let selectedCompanyViewData = recommendationForIndexPath(indexPath)
        coordinator?.showDetail(companyUuid: selectedCompanyViewData.uuid)
    }
    
    public func numberOfRowsInSection(_ section: Int) -> Int {
        return companies.count
    }
    
    public func startPolling() {
        reload()
        let interval: TimeInterval = 120
        pollTimer?.invalidate()
        pollTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let this = self else { return }
            this.reload()
        }
    }
    
    init(coordinator: RecommendationsCoordinator,
         model: RecommendedCompaniesListModelProtocol = RecommendedCompaniesListModel(),
         view: RecommendationsListViewProtocol) {
        self.coordinator = coordinator
        self.model = model
        self.view = view
    }
}

