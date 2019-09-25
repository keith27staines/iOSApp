public protocol F4SCompanyRepositoryProtocol {
    func load(companyUuid: F4SUUID) -> Company?
    func load(companyUuids: [F4SUUID], completion: @escaping (([Company]) -> Void) )
}
