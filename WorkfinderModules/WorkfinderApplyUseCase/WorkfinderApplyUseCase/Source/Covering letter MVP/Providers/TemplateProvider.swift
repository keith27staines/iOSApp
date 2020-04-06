import Foundation

public protocol TemplateProviderProtocol {
    func fetchCoverLetterTemplate(dateOfBirth: Date, completion: @escaping ((Result<TemplateModel,Error>) -> Void))
}

public class TemplateProvider: TemplateProviderProtocol{
    
    var templateString: String
    
    public init(templateString: String = "During my {{role}} placement I want to develop these skills {{skills}}.") {
        self.templateString = templateString
    }
    
    public func fetchCoverLetterTemplate(dateOfBirth: Date, completion: @escaping ((Result<TemplateModel,Error>) -> Void)) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let templateModel = TemplateModel(uuid: "templateUuid", templateString: self.templateString)
            completion(Result<TemplateModel,Error>.success(templateModel))
        }
    }
}
