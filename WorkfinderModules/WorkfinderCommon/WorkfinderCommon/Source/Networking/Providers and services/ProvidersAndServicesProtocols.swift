
import Foundation

public protocol TemplateProviderProtocol {
    func fetchCoverLetterTemplateListJson(completion: @escaping ((Result<TemplateListJson,Error>) -> Void))
}

public protocol PicklistProviderProtocol: class {
    var picklistType: PicklistType { get }
    var moreToCome: Bool { get }
    func fetchMore(completion: @escaping ((Result<[PicklistItemJson],Error>) -> Void))
}

public protocol CompanyWorkplaceListProviderProtocol {
    func fetchCompanyWorkplaces(locationUuids: [F4SUUID],
        completion: @escaping ((Result<Data,Error>) -> Void))
}

public protocol HostsProviderProtocol {
    func fetchHosts(locationUuid: F4SUUID, completion: @escaping((Result<HostListJson,Error>) -> Void) )
}
