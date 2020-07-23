
import WorkfinderCommon

public class TemplateProvider: WorkfinderService, TemplateProviderProtocol {
    
    let candidateAge: Int
    let isProjectString: String
    
    public init(networkConfig: NetworkConfig,
                candidateAge: Int,
                isProject: Bool) {
        self.candidateAge = candidateAge
        self.isProjectString = String(isProject)
        super.init(networkConfig: networkConfig)
    }
    
    public func fetchCoverLetterTemplateListJson(completion: @escaping ((Result<TemplateListJson,Error>) -> Void)) {
        do {
            let request = try buildFetchCoverLetterRequest()
            performTask(
                with: request,
                completion: completion,
                attempting: #function)
        } catch {
            completion(Result<TemplateListJson,Error>.failure(error))
        }
    }
    
    func buildFetchCoverLetterRequest() throws -> URLRequest {
        let minimumAgeString = candidateAge < 18 ? "13" : "18"
        return try buildRequest(
            relativePath: "coverletters/",
            queryItems: [
                URLQueryItem(name: "minimum_age__exact", value: minimumAgeString),
                URLQueryItem(name: "is_project", value: isProjectString)
            ],
            verb: .get)
    }
}

