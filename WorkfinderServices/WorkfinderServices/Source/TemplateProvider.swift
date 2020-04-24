
import WorkfinderCommon

public class TemplateProvider: WorkfinderService, TemplateProviderProtocol {
    
    let candidateDateOfBirth: Date
    lazy var dateOfBirthString: String = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter.string(from: candidateDateOfBirth)
    }()
    
    public init(networkConfig: NetworkConfig,
                candidateDateOfBirth: Date) {
        self.candidateDateOfBirth = candidateDateOfBirth
        super.init(networkConfig: networkConfig)
    }
    
    public func fetchCoverLetterTemplateListJson(completion: @escaping ((Result<TemplateListJson,Error>) -> Void)) {
        do {
            let request = try buildFetchCoverLetterRequest(ageString: dateOfBirthString)
            performTask(
                with: request,
                completion: completion,
                attempting: #function)
        } catch {
            completion(Result<TemplateListJson,Error>.failure(error))
        }
    }
    
    func buildFetchCoverLetterRequest(ageString: String) throws -> URLRequest {
        return try buildRequest(
            relativePath: "coverletters/",
            queryItems: [URLQueryItem(name: "date_of_birth", value: dateOfBirthString)],
            verb: .get)
    }
}
