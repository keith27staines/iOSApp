//
//  ApplicationModel.swift
//  WorkfinderApplyUseCase
//
//  Created by Keith Dev on 29/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

public protocol ApplicationModelProtocol : class {
    var placement: F4SPlacement? { get }
    var placementJson: WEXPlacementJson? { get }
    var availabilityPeriodJson: F4SAvailabilityPeriodJson { get set }
    var applicationLetterModel: ApplicationLetterModelProtocol { get }
    var applicationLetterViewModel: ApplicationLetterViewModelProtocol { get }
    var blanksModel: ApplicationLetterTemplateBlanksModelProtocol { get }
    func createApplicationIfNecessary(completion: @escaping (Error?) -> Void)
}

public class ApplicationModel : ApplicationModelProtocol {
    
    public internal (set) var placement: F4SPlacement?
    public internal (set) var placementJson: WEXPlacementJson?
    public internal (set) var placementService: WEXPlacementServiceProtocol
    public internal (set) var templateService: F4STemplateServiceProtocol
    public internal (set) var companyViewData: CompanyViewDataProtocol
    public internal (set) lazy var localStore: LocalStorageProtocol = { return LocalStore() }()
    
    public internal (set) lazy var userInterests: [F4SInterest] = []
    let placementRepository: F4SPlacementRepositoryProtocol
    let installationUuid: F4SUUID
    var userUuid: F4SUUID
    
    var roleUuid: F4SUUID? {
        return applicationLetterModel.blanksModel.populatedBlankWithName(TemplateBlankName.jobRole)?.choices.first?.uuid
    }
    
    var skills: [F4SUUID]? {
        return applicationLetterModel.blanksModel.populatedBlankWithName(TemplateBlankName.employmentSkills)?.choices.uuidList
    }
    
    var personalAttributes: [F4SUUID]? {
        return applicationLetterModel.blanksModel.populatedBlankWithName(TemplateBlankName.personalAttributes)?.choices.uuidList
    }
    
    public var availabilityPeriodJson: F4SAvailabilityPeriodJson {
        get {
            let defaultAvailabilityPeriodJson: F4SAvailabilityPeriodJson = F4SAvailabilityPeriodJson()
            guard let data = localStore.value(key: LocalStore.Key.availabilityPeriodJsonData) as? Data else {
                return defaultAvailabilityPeriodJson
            }
            do {
                let json = try JSONDecoder().decode(F4SAvailabilityPeriodJson.self, from: data)
                return F4SAvailabilityPeriod(availabilityPeriodJson: json)
                    .nullifyingInvalidStartOrEndDates()
                    .makeAvailabilityPeriodJson()
            } catch {
                return defaultAvailabilityPeriodJson
            }
        }
        set {
            let coder = JSONEncoder()
            let data = try! coder.encode(newValue)
            localStore.setValue(data, for: LocalStore.Key.availabilityPeriodJsonData)
        }
    }
    
    public internal (set) lazy var applicationLetterModel: ApplicationLetterModelProtocol = {
        return ApplicationLetterModel(
            companyName: companyViewData.companyName,
            templateService: self.templateService,
            delegate: nil,
            blanksModel: blanksModel)
    }()
    
    public internal (set) lazy var applicationLetterViewModel: ApplicationLetterViewModelProtocol = {
        let viewModel = ApplicationLetterViewModel(letterModel: applicationLetterModel)
        applicationLetterModel.delegate = viewModel
        return viewModel
    }()
    
    public internal (set) lazy var blanksModel: ApplicationLetterTemplateBlanksModelProtocol = {
        let blanksModel = ApplicationLetterTemplateBlanksModel(store: localStore)
        let availability = availabilityPeriodJson
        let period = F4SAvailabilityPeriod(availabilityPeriodJson: availability)
        blanksModel.updateBlanksFor(firstDay: period.firstDay, lastDay: period.lastDay)
        return blanksModel
    }()
    
    public init(
        userUuid: F4SUUID,
        installationUuid: F4SUUID,
        userInterests: [F4SInterest],
        placement: F4SPlacement?,
        placementRepository: F4SPlacementRepositoryProtocol,
        companyViewData: CompanyViewDataProtocol,
        placementService: WEXPlacementServiceProtocol,
        templateService: F4STemplateServiceProtocol) {
        
        self.userUuid = userUuid
        self.installationUuid = installationUuid
        self.placement = placement
        self.placementRepository = placementRepository
        self.companyViewData = companyViewData
        self.placementService = placementService
        self.templateService = templateService
        self.userInterests = userInterests
    }
    
    public func createApplicationIfNecessary(completion: @escaping ((Error?) -> Void)) -> Void {
        guard placement == nil else {
            placementJson = self.placementJson ?? makePlacementJsonFromPlacement(placement: placement!)
            updatePlacementWithCoverLetterChoices(completion: completion)
            return
        }
        let createPlacementJson = WEXCreatePlacementJson(
            user: self.userUuid,
            roleUuid: self.roleUuid!,
            company: companyViewData.uuid,
            vendor: installationUuid,
            interests: userInterests.uuidList)
        applicationLetterViewModel.modelBusyState(applicationLetterModel, isBusy: true)
        placementService.createPlacement(with: createPlacementJson) { [weak self] (result) in
            guard let strongSelf = self else { return }
            strongSelf.handleResult(
                result,
                completion: completion,
                onStepSuccess: strongSelf.updatePlacementWithCoverLetterChoices,
                onStepRetry: strongSelf.createApplicationIfNecessary)
        }
    }
    
    func updatePlacementWithCoverLetterChoices(completion: @escaping ((Error?) -> Void)) {
        let uuid = (placementJson?.uuid)!
        var patch  = WEXPlacementJson()
        patch.attributes = self.personalAttributes
        patch.skills = self.skills
        patch.availabilityPeriods = [self.availabilityPeriodJson]
        applicationLetterViewModel.modelBusyState(applicationLetterModel, isBusy: true)
        placementService.patchPlacement(uuid: uuid, with: patch) { [weak self] (result) in
            guard let strongSelf = self else { return }
            strongSelf.handleResult(
                result,
                completion: completion,
                onStepSuccess: strongSelf.updatePlacementAsReviewed,
                onStepRetry: strongSelf.updatePlacementWithCoverLetterChoices)
        }
    }
    
    func updatePlacementAsReviewed(completion: @escaping ((Error?) -> Void)) {
        let uuid = (placementJson?.uuid)!
        var patch = WEXPlacementJson()
        patch.reviewed = true
        applicationLetterViewModel.modelBusyState(applicationLetterModel, isBusy: true)
        placementService.patchPlacement(uuid: uuid, with: patch) { [weak self] (result) in
            guard let strongSelf = self else { return }
            strongSelf.handleResult(
                result,
                completion: completion,
                onStepSuccess: strongSelf.applicationSubmitted,
                onStepRetry: strongSelf.updatePlacementAsReviewed)
        }
    }
    
    func applicationSubmitted(completion: ((Error?) -> Void)) {
        completion(nil)
    }
    
    func handleResult(
        _ result: WEXResult<WEXPlacementJson, WEXError>,
        completion: @escaping ((Error?) -> Void),
        onStepSuccess: @escaping ((@escaping (Error?) -> Void)) -> Void,
        onStepRetry: @escaping ((@escaping (Error?) -> Void)) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard
                let strongSelf = self,
                let applicationLetterViewModel = self?.applicationLetterViewModel,
                let letterModel = self?.applicationLetterModel else { return }
            
            applicationLetterViewModel.modelBusyState(letterModel, isBusy: false)
            switch result {
            case .failure(let error):
                applicationLetterViewModel.applicationLetterModel(letterModel, failedToSubmitLetter: error, retry: {
                    onStepRetry(completion)
                })
            case .success(let placementJson):
                strongSelf.placementJson = placementJson
                let placement = strongSelf.makeF4SPlacementFromResponseJson(json: placementJson)
                strongSelf.placementRepository.save(placement: placement)
                strongSelf.placement = placement
                onStepSuccess(completion)
            }
        }
    }
}

extension ApplicationModel {
    func makePlacementJsonFromPlacement(placement: F4SPlacement) -> WEXPlacementJson {
        return WEXPlacementJson(uuid: placement.placementUuid, user: userUuid, company: placement.companyUuid!, vendor: installationUuid, interests: userInterests.uuidList)
    }
    
    func makeF4SPlacementFromResponseJson(json: WEXPlacementJson) -> F4SPlacement {
        var placement = F4SPlacement(
            userUuid: json.userUuid,
            companyUuid: json.companyUuid,
            interestList: [],
            status: json.workflowState,
            placementUuid: json.uuid)
        placement.placementUuid = json.uuid
        return placement
    }
}

public extension Sequence where Iterator.Element == F4SChoice {
    var uuidList: [F4SUUID] {
        return map({ (choice) -> F4SUUID in
            choice.uuid
        })
    }
}
