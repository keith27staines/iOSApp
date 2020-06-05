
import WorkfinderCommon

public protocol CompanyServiceProtocol {
    func fetchCompany(uuid: F4SUUID, completion: @escaping (Result<CompanyJson,Error>) -> Void)
}

public class CompanyService: WorkfinderService, CompanyServiceProtocol {
    
    public func fetchCompany(uuid: F4SUUID, completion: @escaping (Result<CompanyJson,Error>) -> Void) {
        do {
            let relativePath = "companies/\(uuid)"
            let request = try buildRequest(relativePath: relativePath, queryItems: nil, verb: .get)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(Result<CompanyJson,Error>.failure(error))
        }
    }

}
