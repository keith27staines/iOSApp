import Foundation

public struct PicklistServerJson: Codable {
    var next: String?
    var previous: String?
    var results: [PicklistItemJson]
}

public struct PicklistItemJson: Codable {
    var uuid: String?
    var value: String?
    public init(uuid: String, value: String) {
        self.uuid = uuid
        self.value = value
    }
}

extension PicklistItemJson {
    private enum codingKeys: String, CodingKey {
        case uuid
        case value = "display_name"
    }
}

extension Picklist.PicklistType {
    var endpoint: String {
        switch self {
        case .roles: return "job-roles/"
        case .skills: return "employment-skills/"
        case .attributes: return "personal-attributes/"
        case .universities: return "institutions/"
        }
    }
}

public class PicklistProvider: PicklistProviderProtocol {
    
    public let picklistType: Picklist.PicklistType
    public var moreToCome: Bool = false
    let apiUrl: String = "http://workfinder-develop.eu-west-2.elasticbeanstalk.com/v3/"
    let urlString: String
    let urlRequest: URLRequest
    var completionHandler: ((Result<[PicklistItemJson],Error>) -> Void)?
    let url: URL
    let session: URLSession = URLSession(configuration: URLSessionConfiguration.default)
    var task: URLSessionDataTask?
    
    public init(picklistType: Picklist.PicklistType) {
        self.picklistType = picklistType
        urlString = apiUrl + picklistType.endpoint
        url = URL(string: urlString)!
        urlRequest = URLRequest(url: url)
    }
    
    public func fetchMore(completion: @escaping ((Result<[PicklistItemJson],Error>) -> Void)) {
        self.completionHandler = completion
        task?.cancel()
        task = session.dataTask(with: urlRequest, completionHandler: taskCompletionHandler)
        task?.resume()
    }
    
    func networkResultHandler(_ result: Result<Data,Error>) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                do {
                    let responseJson = try JSONDecoder().decode(PicklistServerJson.self, from: data)
                    let results = responseJson.results
                    self.completionHandler?(Result<[PicklistItemJson],Error>.success(results))
                } catch {
                    self.completionHandler?(Result<[PicklistItemJson],Error>.failure(error))
                }
            case .failure(let error):
                self.completionHandler?(Result<[PicklistItemJson],Error>.failure(error))
            }
        }
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
}



