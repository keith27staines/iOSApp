
import Foundation
import WorkfinderCommon
import WorkfinderAppLogic

protocol ApplicationModelProtocol : class {
    var availabilityPeriodJson: F4SAvailabilityPeriodJson { get set }
    var applicationLetterModel: ApplicationLetterModelProtocol { get }
    var applicationLetterViewModel: ApplicationLetterViewModelProtocol { get }
    var blanksModel: ApplicationLetterTemplateBlanksModelProtocol { get }
    var motivationTextModel: MotivationTextModel { get }
    func createApplication(completion: @escaping (Error?) -> Void)
}

class ApplicationModel : ApplicationModelProtocol {
    
    public internal (set) var templateService: F4STemplateServiceProtocol
    public internal (set) var companyWorkplace: CompanyWorkplace
    public internal (set) var host: F4SHost?
    public internal (set) lazy var localStore: LocalStorageProtocol = { return LocalStore() }()
    
    public internal (set) lazy var userInterests: [F4SInterest] = []
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
            companyName: self.companyWorkplace.companyJson.name ?? "unnamed company",
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
        companyWorkplace: CompanyWorkplace,
        host: F4SHost? = nil,
        templateService: F4STemplateServiceProtocol) {
        
        self.userUuid = userUuid
        self.installationUuid = installationUuid
        self.companyWorkplace = companyWorkplace
        self.host = host
        self.templateService = templateService
        self.userInterests = userInterests
    }
    
    func createApplication(completion: @escaping ((Error?) -> Void)) -> Void {

    }
    
    func updatePlacementWithCoverLetterChoices(completion: @escaping ((Error?) -> Void)) {

    }
    
    func updatePlacementAsReviewed(completion: @escaping ((Error?) -> Void)) {

    }
    
    func applicationSubmitted(completion: ((Error?) -> Void)) {
        completion(nil)
    }
    
    func handleResult(
        _ result: F4SNetworkResult<String>,
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

                onStepSuccess(completion)
            }
        }
    }
}

extension Sequence where Iterator.Element == F4SChoice {
    var uuidList: [F4SUUID] {
        return map({ (choice) -> F4SUUID in
            choice.uuid
        })
    }
}
