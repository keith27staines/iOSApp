
import WorkfinderCommon

public class TemplateProvider: WorkfinderService, TemplateProviderProtocol {
    
    let candidateAge: Int
    let isProject: Bool
    
    public init(networkConfig: NetworkConfig,
                candidateAge: Int,
                isProject: Bool) {
        self.candidateAge = candidateAge
        self.isProject = isProject
        super.init(networkConfig: networkConfig)
    }
    
    var completion: ((Result<[TemplateModel],Error>) -> Void)?
    
    public func fetchCoverLetterTemplateListJson(completion: @escaping ((Result<[TemplateModel],Error>) -> Void)) {
        self.completion = completion
        do {
            let request = try buildRequest(relativePath: "coverletters/", queryItems: nil, verb: .get)
            performTask(
                with: request,
                completion: processResult,
                attempting: #function)
        } catch {
            completion(Result<[TemplateModel],Error>.failure(error))
        }
    }
    
    func processResult(_ result: Result<TemplateListJson,Error>) -> Void {
        switch result {
        case .success(let templateList):
            let firstMatch = templateList.results.filter { (model) -> Bool in
                (model.isProject == false || model.isProject == nil) && model.minimumAge == 13
            }.first
            if let match = firstMatch {
                completion?(Result<[TemplateModel],Error>.success([match]))
            } else {
                completion?(Result<[TemplateModel],Error>.success([]))
            }
        case .failure(let error):
            completion?(Result<[TemplateModel],Error>.failure(error))
        }
    }
    
//    func processResult(_ result: Result<TemplateListJson,Error>) -> Void {
//        switch result {
//        case .success(let templateList):
//            let firstMatch = templateList.results.filter { (model) -> Bool in
//                if isProject {
//                    return model.isProject == true
//                } else {
//                    return model.isProject == false || model.isProject == nil
//                }
//            }.filter { (model) -> Bool in
//                guard let modelMinimumAge = model.minimumAge else { return false }
//                return modelMinimumAge <= candidateAge
//            }.sorted {
//                $0.minimumAge ?? 0 > $1.minimumAge ?? 0
//            }.first
//            if let match = firstMatch {
//                completion?(Result<[TemplateModel],Error>.success([match]))
//            } else {
//                completion?(Result<[TemplateModel],Error>.success([]))
//            }
//        case .failure(let error):
//            completion?(Result<[TemplateModel],Error>.failure(error))
//        }
//    }
    
//    func buildFetchCoverLetterRequest() throws -> URLRequest {
//        let minimumAgeString = candidateAge < 18 ? "13" : "18"
//        return try buildRequest(
//            relativePath: "coverletters/",
//            queryItems: [
//                URLQueryItem(name: "minimum_age__exact", value: minimumAgeString),
//                URLQueryItem(name: "is_project", value: isProjectString)
//            ],
//            verb: .get)
//    }
}

