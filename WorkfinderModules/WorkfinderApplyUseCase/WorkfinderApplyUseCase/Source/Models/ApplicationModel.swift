
import Foundation
import WorkfinderCommon
import WorkfinderAppLogic

protocol ApplicationModelProtocol : class {
    var voucherCode: String? { get set }
    var placement: F4SPlacement? { get }
    var placementJson: F4SPlacementJson? { get }
    var availabilityPeriodJson: F4SAvailabilityPeriodJson { get set }
    var applicationLetterModel: ApplicationLetterModelProtocol { get }
    var applicationLetterViewModel: ApplicationLetterViewModelProtocol { get }
    var blanksModel: ApplicationLetterTemplateBlanksModelProtocol { get }
    var motivationTextModel: MotivationTextModel { get }
    func resumeApplicationFromPreexistingDraft(_ draft: F4SPlacement, completion: @escaping ((Error?) -> Void))
    func createApplication(completion: @escaping (Error?) -> Void)
}

class ApplicationModel : ApplicationModelProtocol {
    
    public var voucherCode: F4SUUID?
    public internal (set) var placement: F4SPlacement?
    public internal (set) var placementJson: F4SPlacementJson?
    public internal (set) var placementService: F4SPlacementApplicationServiceProtocol
    public internal (set) var templateService: F4STemplateServiceProtocol
    public internal (set) var companyViewData: CompanyViewDataProtocol
    public internal (set) var host: F4SHost?
    public internal (set) lazy var localStore: LocalStorageProtocol = { return LocalStore() }()
    
    public internal (set) lazy var userInterests: [F4SInterest] = []
    let placementRepository: F4SPlacementRepositoryProtocol
    let installationUuid: F4SUUID
    var userUuid: F4SUUID
    
    lazy var motivationRepository: F4SMotivationRepositoryProtocol = {
        return F4SMotivationRepository(localStore: self.localStore)
    }()
    
    lazy var motivationTextModel: MotivationTextModel = {
        return MotivationTextModel(repo: self.motivationRepository)
    }()
    
    var motivationType: MotivationTextOption {
        guard let useDefaultMotivation = localStore.value(key: LocalStore.Key.useDefaultMotivation) as? Bool else {
            return .standard
        }
        return useDefaultMotivation ? MotivationTextOption.standard : MotivationTextOption.custom
    }
    
    var motivation: String? {
        get { return motivationTextModel.text }
        set { motivationTextModel.text = newValue ?? ""}
    }
    
    var roleUuid: F4SUUID? {
        return applicationLetterModel.blanksModel.populatedBlankWithName(TemplateBlankName.jobRole)?.choices.first?.uuid
    }
    
    var skills: [F4SUUID]? {
        return applicationLetterModel.blanksModel.populatedBlankWithName(TemplateBlankName.employmentSkills)?.choices.uuidList
    }
    
    var personalAttributes: [F4SUUID]? {
        return applicationLetterModel.blanksModel.populatedBlankWithName(TemplateBlankName.personalAttributes)?.choices.uuidList
    }
    
    var availabilityPeriodJson: F4SAvailabilityPeriodJson {
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
    
    lazy var applicationLetterModel: ApplicationLetterModelProtocol = {
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
    
    lazy var blanksModel: ApplicationLetterTemplateBlanksModelProtocol = {
        let blanksModel = ApplicationLetterTemplateBlanksModel(store: localStore)
        let availability = availabilityPeriodJson
        let period = F4SAvailabilityPeriod(availabilityPeriodJson: availability)
        blanksModel.updateBlanksFor(firstDay: period.firstDay, lastDay: period.lastDay)
        return blanksModel
    }()
    
    init(
        userUuid: F4SUUID,
        installationUuid: F4SUUID,
        userInterests: [F4SInterest],
        placement: F4SPlacement?,
        placementRepository: F4SPlacementRepositoryProtocol,
        companyViewData: CompanyViewDataProtocol,
        host: F4SHost? = nil,
        placementService: F4SPlacementApplicationServiceProtocol,
        templateService: F4STemplateServiceProtocol) {
        
        self.userUuid = userUuid
        self.installationUuid = installationUuid
        self.placement = placement
        self.placementRepository = placementRepository
        self.companyViewData = companyViewData
        self.host = host
        self.placementService = placementService
        self.templateService = templateService
        self.userInterests = userInterests
    }
    
    func resumeApplicationFromPreexistingDraft(_ draft: F4SPlacement, completion: @escaping ((Error?) -> Void)) {
        self.placement = draft
        placementJson = makePlacementJsonFromPlacement(placement: draft)
        updatePlacementWithCoverLetterChoices(completion: completion)
    }
    
    func createApplication(completion: @escaping ((Error?) -> Void)) -> Void {
        precondition(placement == nil, "If placement exists already, use `continueFromPreexistingDraftPlacement`")
        let createPlacementJson = F4SCreatePlacementJson(
            user: self.userUuid,
            roleUuid: self.roleUuid!,
            company: companyViewData.uuid,
            hostUuid: host?.uuid,
            vendor: installationUuid,
            interests: userInterests.uuidList)
        applicationLetterViewModel.modelBusyState(applicationLetterModel, isBusy: true)
        placementService.apply(with: createPlacementJson) { [weak self] (result) in
            guard let strongSelf = self else { return }
            strongSelf.handleResult(
                result,
                completion: completion,
                onStepSuccess: strongSelf.updatePlacementWithCoverLetterChoices,
                onStepRetry: strongSelf.createApplication)
        }
    }
    
    func updatePlacementWithCoverLetterChoices(completion: @escaping ((Error?) -> Void)) {
        let uuid = (placementJson?.uuid)!
        var patch  = F4SPlacementJson()
        patch.attributes = self.personalAttributes
        patch.skills = self.skills
        patch.availabilityPeriods = [self.availabilityPeriodJson]
        patch.motivation = motivation
        applicationLetterViewModel.modelBusyState(applicationLetterModel, isBusy: true)
        placementService.update(uuid: uuid, with: patch) { [weak self] (result) in
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
        var patch = F4SPlacementJson()
        patch.reviewed = true
        applicationLetterViewModel.modelBusyState(applicationLetterModel, isBusy: true)
        placementService.update(uuid: uuid, with: patch) { [weak self] (result) in
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
        _ result: F4SNetworkResult<F4SPlacementJson>,
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
            case .error(let error):
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
    func makePlacementJsonFromPlacement(placement: F4SPlacement) -> F4SPlacementJson {
        return F4SPlacementJson(uuid: placement.placementUuid, user: userUuid, company: placement.companyUuid!, vendor: installationUuid, interests: userInterests.uuidList)
    }
    
    func makeF4SPlacementFromResponseJson(json: F4SPlacementJson) -> F4SPlacement {
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

extension Sequence where Iterator.Element == F4SChoice {
    var uuidList: [F4SUUID] {
        return map({ (choice) -> F4SUUID in
            choice.uuid
        })
    }
}
