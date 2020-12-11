
import WorkfinderCommon

public typealias WorkplaceAndAssociationUuid = (Workplace,F4SUUID)

public class WorkplaceAndAssociationService {
    var recommendationUuid: F4SUUID?
    let recommendationService: RecommendationsServiceProtocol
    let associationService: AssociationsServiceProtocol
    let locationService: LocationServiceProtocol
    let companyService: CompanyServiceProtocol
    
    var recommendation: RecommendationsListItem?
    public internal (set) var associationJson: AssociationJson?
    var companyLocationJson: CompanyLocationJson?
    var companyJson: CompanyJson?
    
    var completion: ((Result<WorkplaceAndAssociationUuid,Error>) -> Void)?
    
    public init(networkConfig: NetworkConfig) {
        self.associationService = AssociationsService(networkConfig: networkConfig)
        self.recommendationService = RecommendationsService(networkConfig: networkConfig)
        self.locationService = LocationService(networkConfig: networkConfig)
        self.companyService = CompanyService(networkConfig: networkConfig)
    }
    
    public func fetchCompanyWorkplace(
        recommendationUuid: F4SUUID,
        completion: @escaping (Result<WorkplaceAndAssociationUuid,Error>) -> Void) {
        self.completion = completion
        recommendationService.fetchRecommendation(uuid: recommendationUuid) { (result) in
            switch result {
            case .success(let recommendation):
                self.recommendation = recommendation
                self.onRecommendationFetched()
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    public func fetchCompanyWorkplace(
        associationUuid: F4SUUID,
        completion: @escaping (Result<WorkplaceAndAssociationUuid,Error>) -> Void) {
        self.completion = completion
        associationService.fetchAssociation(uuid: associationUuid) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let associationJson):
                self.associationJson = associationJson
                self.onAssociationFetched()
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    func handleError(_ error: Error) {
        completion?(Result<WorkplaceAndAssociationUuid,Error>.failure(error))
    }
    
    func handleSuccess(_ value: WorkplaceAndAssociationUuid) {
        completion?(Result<WorkplaceAndAssociationUuid,Error>.success(value))
    }
    
    func onRecommendationFetched() {
        guard
            let recommendation = recommendation,
            let associationUuid = recommendation.project?.association?.uuid else {
            let error = WorkfinderError(title: "Invalid recommendation", description: "The recommendation is nil or its association is nil")
            handleError(error)
            return
        }
        guard let completion = completion else {
            let error = WorkfinderError(title: "No completion handler", description: "Either the completion handler was never set or it has been nulled")
            handleError(error)
            return
        }
        fetchCompanyWorkplace(associationUuid: associationUuid, completion: completion)
    }
    
    func onAssociationFetched() {
        guard let associationJson = associationJson
            else {
                let error = WorkfinderError(title: "Association missing", description: "The association hasn't been fetched from the server")
                handleError(error)
                return
        }
        //companyLocationJson = associationJson.location
        onLocationFetched()
    }
    
    func onLocationFetched() {
        guard
            let location = self.companyLocationJson,
            let companyUuid = location.company?.uuid
            else {
                let error = WorkfinderError(title: "Company not found", description: "Either the location hasn't been fetched from the server or the location doesn't have a company")
                handleError(error)
            return
        }
        companyService.fetchCompany(uuid: companyUuid) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let companyJson):
                self.companyJson = companyJson
                self.onCompanyFetched()
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    func onCompanyFetched() {
        guard
            let companyJson = self.companyJson,
            let location = self.companyLocationJson
            else {
                let error = WorkfinderError(title: "No workplace", description: "Either the company or the location is missing, or both are missing")
                handleError(error)
                return
        }
        guard
            let locationUuid = location.uuid,
            let latitude = location.geometry?.latitude,
            let longitude = location.geometry?.longitude
            else {
                let error = WorkfinderError(title: "Location is incomplete", description: "The location is missing latitude and/or longitude")
                handleError(error)
                return
        }
        guard let recommendedAssociationUuid = associationJson?.uuid
            else {
                let error = WorkfinderError(title: "The association has no uuid", description: "The association's uuid is nil")
                handleError(error)
                return
        }
        let pinJson = PinJson(workplaceUuid: locationUuid,
                              latitude: Double(latitude),
                              longitude: Double(longitude))
        let workplace = Workplace(companyJson: companyJson, pinJson: pinJson)
        handleSuccess((workplace, recommendedAssociationUuid))
    }
}

