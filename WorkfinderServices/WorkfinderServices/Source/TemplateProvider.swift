
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
                verbose: true,
                completion: processResult,
                attempting: #function)
        } catch {
            completion(Result<[TemplateModel],Error>.failure(error))
        }
    }
    
    func processResult(_ result: Result<TemplateListJson,Error>) -> Void {
        switch result {
        case .success(let templateList):
            
            if isProject {
                guard let firstMatch = templateList.results.filter({ (model) -> Bool in
                    model.isProject == true && model.minimumAge == 18
                }).first else {
                    completion?(.success([]))
                    return
                }
                completion?(Result.success([firstMatch]))
                return
                
            } else {
                guard let firstMatch = templateList.results.filter({ (model) -> Bool in
                    (model.isProject == false || model.isProject == nil) && model.minimumAge == 13
                }).first else {
                    completion?(.success([]))
                    return
                }
                completion?(Result.success([firstMatch]))
            }

        case .failure(let error):
            completion?(Result<[TemplateModel],Error>.failure(error))
        }
    }
}

