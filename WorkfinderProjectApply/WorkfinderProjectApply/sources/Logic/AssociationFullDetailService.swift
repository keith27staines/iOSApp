
import WorkfinderCommon
import WorkfinderServices


protocol AssociationDetailServiceProtocol: AnyObject {
    func fetchAssociationDetail(associationUuid: F4SUUID, completion: @escaping (Result<AssociationDetail, Error>) -> Void)
    
}

class AssociationDetailService: AssociationDetailServiceProtocol {
    
    var associationService: AssociationsServiceProtocol
    var locationService: LocationServiceProtocol
    var hostService: HostsProviderProtocol
    var companyService: CompanyServiceProtocol
    var associationDetail = AssociationDetail()
    
    var completion: ((Result<AssociationDetail, Error>) -> Void)?
    
    init(networkConfig: NetworkConfig) {
        associationService = AssociationsService(networkConfig: networkConfig)
        locationService = LocationService(networkConfig: networkConfig)
        hostService = HostsProvider(networkConfig: networkConfig)
        companyService = CompanyService(networkConfig: networkConfig)
    }
    
    func fetchAssociationDetail(associationUuid: F4SUUID, completion: @escaping (Result<AssociationDetail, Error>) -> Void) {
        self.completion = completion
        loadAssociation(associationUuid: associationUuid)
    }
    
    private func loadAssociation(associationUuid: F4SUUID) {
        let association = associationDetail.association
        guard association == nil else {
            onAssociationLoaded(association: association!)
            return
        }
        associationService.fetchAssociation(uuid: associationUuid) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let association):
                self.onAssociationLoaded(association: association)
            case .failure(let error):
                guard (error as? WorkfinderError)?.retry == true else {
                    self.completion?(Result<AssociationDetail, Error>.failure(error))
                    return
                }
                self.loadAssociation(associationUuid: associationUuid)
            }
        }
    }
    
    private func onAssociationLoaded(association: AssociationJson) {
        associationDetail.association = association
        loadHost(hostUuid: association.host.uuid!)
    }
    
    private func loadHost(hostUuid: F4SUUID) {
        let host = associationDetail.host
        guard host == nil else {
            onHostLoaded(host: host!)
            return
        }
        hostService.fetchHost(uuid: hostUuid) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let host):
                self.onHostLoaded(host: host)
            case .failure(let error):
                guard (error as? WorkfinderError)?.retry == true else {
                    self.completion?(Result<AssociationDetail, Error>.failure(error))
                    return
                }
                self.loadHost(hostUuid: hostUuid)
            }
        }
    }
    
    private func onHostLoaded(host: Host) {
        associationDetail.host = host
        guard let locationUuid = associationDetail.association?.location.uuid else {
            completion?(Result<AssociationDetail, Error>.success(associationDetail))
            return
        }
        loadLocation(locationUuid: locationUuid)
    }
    
    private func loadLocation(locationUuid: F4SUUID) {
        let location = associationDetail.location
        guard location == nil else {
            onLocationLoaded(location: location!)
            return
        }
        locationService.fetchLocation(locationUuid: locationUuid) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let location):
                self.onLocationLoaded(location: location)
            case .failure(let error):
                guard (error as? WorkfinderError)?.retry == true else {
                    self.completion?(Result<AssociationDetail, Error>.failure(error))
                    return
                }
                self.loadLocation(locationUuid: locationUuid)
            }
        }
    }
    
    private func onLocationLoaded(location: CompanyLocationJson) {
        associationDetail.location = location
        guard let companyUuid = location.company?.uuid else {
            completion?(Result<AssociationDetail, Error>.success(associationDetail))
            return
        }
        loadCompany(companyUuid: companyUuid)
    }
    
    private func loadCompany(companyUuid: F4SUUID) {
        let company = associationDetail.company
        guard company == nil else {
            onCompanyLoaded(company: company!)
            return
        }
        companyService.fetchCompany(uuid: companyUuid) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let company):
                self.onCompanyLoaded(company: company)
            case .failure(let error):
                guard (error as? WorkfinderError)?.retry == true else {
                    self.completion?(Result<AssociationDetail, Error>.failure(error))
                    return
                }
                self.loadCompany(companyUuid: companyUuid)
            }
        }
    }
    
    private func onCompanyLoaded(company: CompanyJson) {
        associationDetail.company = company
        self.completion?(Result<AssociationDetail, Error>.success(associationDetail))
    }
}

