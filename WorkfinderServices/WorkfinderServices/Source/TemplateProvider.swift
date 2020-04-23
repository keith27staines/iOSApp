
import WorkfinderCommon

public class TemplateProvider: WorkfinderService, TemplateProviderProtocol {
    
    var completion: ((Result<TemplateListJson, Error>) -> Void)?
    let candidateDateOfBirth: Date
    
    public init(networkConfig: NetworkConfig,
                candidateDateOfBirth: Date) {
        self.candidateDateOfBirth = candidateDateOfBirth
        super.init(networkConfig: networkConfig)
    }
    
    public func fetchCoverLetterTemplateListJson(completion: @escaping ((Result<TemplateListJson,Error>) -> Void)) {
        task?.cancel()
        let request = buildRequest(ageString: dateOfBirthString)
        self.completion = completion
        task = session.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            guard let self = self else { return }
            self.taskHandler.convertToDataResult(data: data, response: response, error: error, completion: self.deserializeDataResult)
            
        })
        task?.resume()
    }
}

extension TemplateProvider {
    
    var dateOfBirthString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter.string(from: candidateDateOfBirth)
    }
    
    func buildRequest(ageString: String) -> URLRequest {
        var components = urlComponents
        components.path = urlComponents.path + "coverletters/"
        components.queryItems = [URLQueryItem(name: "date_of_birth", value: dateOfBirthString)]
        let url = components.url!
        return networkConfig.buildUrlRequest(url: url, verb: .get, body: nil)
    }
    
    func deserializeDataResult(_ result: Result<Data,Error>) {
        guard let completion = completion else { return }
        deserialise(dataResult: result, completion: completion)
    }
}
