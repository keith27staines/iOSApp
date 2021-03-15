
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
            
            guard let defaultTemplate = templateList.results.first(where: { (template) -> Bool in
                template.isDefault == true
            }) else {
                let firstMatch = templateList.results.filter { (model) -> Bool in
                    (model.isProject == false || model.isProject == nil) && model.minimumAge == 13
                }.first
                if let match = firstMatch {
                    completion?(Result<[TemplateModel],Error>.success([match]))
                } else {
                    completion?(Result<[TemplateModel],Error>.success([]))
                }
                return
            }
            completion?(Result.success([defaultTemplate]))

        case .failure(let error):
            completion?(Result<[TemplateModel],Error>.failure(error))
        }
    }
}

