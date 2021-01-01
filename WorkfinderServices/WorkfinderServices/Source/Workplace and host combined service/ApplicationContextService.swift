
import WorkfinderCommon

public typealias WorkplaceAndAssociationUuid = (CompanyAndPin,F4SUUID)

public struct ApplicationContext {
    public var recommendationUuid: F4SUUID?
    public var associationUuid: F4SUUID?
    
    public var recommendationJson: RecommendationsListItem?
    public var associationJson: AssociationJson?
    public var locationJson: CompanyNestedLocationJson?
    public var companyJson: CompanyJson?
    public var hostJson: HostJson?
    public var pin: LocationPin?
    public var companyAndPin: CompanyAndPin?
}

public class ApplicationContextService {
    var recommendationUuid: F4SUUID?
    let recommendationService: RecommendationsServiceProtocol
    let associationService: AssociationsServiceProtocol
    let locationService: LocationServiceProtocol
    let companyService: CompanyServiceProtocol

    public internal (set) var context = ApplicationContext()
    
    var completion: ((Result<ApplicationContext,Error>) -> Void)?
    
    public init(networkConfig: NetworkConfig) {
        self.associationService = AssociationsService(networkConfig: networkConfig)
        self.recommendationService = RecommendationsService(networkConfig: networkConfig)
        self.locationService = LocationService(networkConfig: networkConfig)
        self.companyService = CompanyService(networkConfig: networkConfig)
    }
    
    public func fetchStartingFrom(
        recommendationUuid: F4SUUID,
        completion: @escaping (Result<ApplicationContext,Error>
    ) -> Void) {
        self.completion = completion
        context.recommendationUuid = recommendationUuid
        recommendationService.fetchRecommendation(uuid: recommendationUuid) { (result) in
            switch result {
            case .success(let recommendation):
                self.context.recommendationJson = recommendation
                self.onRecommendationFetched()
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    public func fetchStartingFrom(
        associationUuid: F4SUUID,
        completion: @escaping (Result<ApplicationContext,Error>) -> Void
    ) {
        self.completion = completion
        context.associationUuid = associationUuid
        associationService.fetchAssociation(uuid: associationUuid) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let associationJson):
                self.context.associationJson = associationJson
                self.onAssociationFetched()
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    func handleError(_ error: Error) {
        completion?(.failure(error))
    }
    
    func handleSuccess(_ value: ApplicationContext) {
        completion?(.success(value))
    }
    
    func onRecommendationFetched() {
        guard
            let recommendation = context.recommendationJson,
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
        fetchStartingFrom(associationUuid: associationUuid, completion: completion)
    }
    
    func onAssociationFetched() {
        guard let associationJson = context.associationJson
            else {
                let error = WorkfinderError(title: "Association missing", description: "The association hasn't been fetched from the server")
                handleError(error)
                return
        }
        let locationUuid = associationJson.locationUuid
        locationService.fetchLocation(locationUuid: locationUuid) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let locationJson):
                self.context.locationJson = locationJson
                self.onLocationFetched()
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    func onLocationFetched() {
        guard
            let location = context.locationJson,
            let companyUuid = location.companyUuid
            else {
                let error = WorkfinderError(title: "Company not found", description: "Either the location hasn't been fetched from the server or the location doesn't have a company")
                handleError(error)
            return
        }
        companyService.fetchCompany(uuid: companyUuid) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let companyJson):
                self.context.companyJson = companyJson
                self.onCompanyFetched()
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    func onCompanyFetched() {
        guard
            let companyJson = context.companyJson,
            let location = context.locationJson
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
        let pin = LocationPin(locationUuid: locationUuid,
                              latitude: Double(latitude),
                              longitude: Double(longitude))
        let companyAndPin = CompanyAndPin(companyJson: companyJson, locationPin: pin)
        context.pin = pin
        context.companyAndPin = companyAndPin
        handleSuccess((context))
    }
}

