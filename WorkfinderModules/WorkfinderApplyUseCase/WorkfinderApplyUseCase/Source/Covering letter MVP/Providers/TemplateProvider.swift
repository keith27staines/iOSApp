import Foundation

public protocol TemplateProviderProtocol {
    func fetchCoverLetterTemplate(completion: @escaping ((Result<TemplateModel,Error>) -> Void))
}

fileprivate let testTemplate = TemplateModel(uuid: "", templateString:
    """
       Dear Sir/Madam
       {{free text 1}}
       I would like to apply for the {{role}} role at your company.
       I wish to acquire the following skills: {{skills}}.
       I consider myself to have the following personal attributes: {{attributes}}.
       I am in year {{year}} of study at {{university}}.
       {{free text 2}}
       I will be available between {{availability}}
       {{free text 3}}
    """)

public class TemplateProvider: TemplateProviderProtocol{
    
    let apiUrl: String
    let templateString: String = "During my {{role}} placement I want to develop these skills {{skills}}."
    var completionHandler: ((Result<TemplateModel,Error>) -> Void)?
    let session: URLSession = URLSession(configuration: URLSessionConfiguration.default)
    var task: URLSessionDataTask?
    let candidateDateOfBirth: Date
    
    var dateOfBirthString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter.string(from: candidateDateOfBirth)
    }
    
    public init(apiUrl: String = "http://workfinder-develop.eu-west-2.elasticbeanstalk.com/v3/",
                candidateDateOfBirth: Date) {
        self.apiUrl = apiUrl
        self.candidateDateOfBirth = candidateDateOfBirth
    }
    
    public func fetchCoverLetterTemplate(completion: @escaping ((Result<TemplateModel,Error>) -> Void)) {
        task?.cancel()
        self.completionHandler = completion
        let url = URL(string: apiUrl + "coverletters/")!
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [URLQueryItem(name: "date_of_birth", value: dateOfBirthString)]
        let urlRequest = URLRequest(url: urlComponents.url!)
        task = session.dataTask(with: urlRequest, completionHandler: taskCompletionHandler)
        task?.resume()
    }
    
    func taskCompletionHandler(data: Data?, response: URLResponse?, error: Error?) {
        guard let response = response as? HTTPURLResponse else {
            if let error = error {
                let result = Result<Data, Error>.failure(error)
                networkResultHandler(result)
                return
            }
            return
        }
        let code = response.statusCode
        switch code {
        case 200..<300:
            guard let  data = data else {
                let httpError = NetworkError.responseBodyEmpty(response)
                let result = Result<Data, Error>.failure(httpError)
                networkResultHandler(result)
                return
            }
            networkResultHandler(Result<Data,Error>.success(data))
        default:
            let httpError = NetworkError.httpError(response)
            let result = Result<Data, Error>.failure(httpError)
            networkResultHandler(result)
            return
        }
    }
    
    func networkResultHandler(_ result: Result<Data,Error>) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                do {
                    let responseJson = try JSONDecoder().decode(TemplateListJson.self, from: data)
                    let templateModel = responseJson.results.first ?? testTemplate
                    self.completionHandler?(Result<TemplateModel,Error>.success(templateModel))
                } catch {
                    let deserializationError = NetworkError.deserialization(error)
                    self.completionHandler?(Result<TemplateModel,Error>.failure(deserializationError))
                }
            case .failure(let error):
                self.completionHandler?(Result<TemplateModel,Error>.failure(error))
            }
        }
    }
}
