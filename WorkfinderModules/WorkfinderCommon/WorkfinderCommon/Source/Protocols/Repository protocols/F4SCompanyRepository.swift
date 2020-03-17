public protocol F4SCompanyRepositoryProtocol {
    func load(companyUuids: [F4SUUID], completion: @escaping (([F4SCompanyJson]) -> Void) )
}
