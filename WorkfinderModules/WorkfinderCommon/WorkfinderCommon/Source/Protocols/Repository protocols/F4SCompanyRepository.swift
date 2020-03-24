public protocol F4SCompanyRepositoryProtocol {
    func load(companyUuids: [F4SUUID], completion: @escaping (([CompanyJson]) -> Void) )
}
