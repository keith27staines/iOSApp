
import Foundation

public protocol TemplateProviderProtocol {
    func fetchCoverLetterTemplateListJson(completion: @escaping ((Result<TemplateListJson,Error>) -> Void))
}

public protocol PicklistProviderProtocol: class {
    var picklistType: PicklistType { get }
    func fetchPicklistItems(completion: @escaping ((Result<PicklistServerJson,Error>) -> Void))
}

public protocol CompanyWorkplaceListProviderProtocol {
    func fetchCompanyWorkplaces(
        locationUuids: [F4SUUID],
        completion: @escaping ((Result<CompanyListJson,Error>) -> Void))
}

public protocol HostsProviderProtocol {
    func fetchHosts(locationUuid: F4SUUID, completion: @escaping((Result<HostListJson,Error>) -> Void) )
}
