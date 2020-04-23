
import WorkfinderCommon

public class PicklistProvider: PicklistProviderProtocol {
    
    public let picklistType: PicklistType
    public var moreToCome: Bool = false
    let apiUrl: URL
    let urlRequest: URLRequest
    var completionHandler: ((Result<[PicklistItemJson],Error>) -> Void)?
    let url: URL
    let session: URLSession = URLSession(configuration: URLSessionConfiguration.default)
    var task: URLSessionDataTask?
    
    public init(picklistType: PicklistType, networkConfig: NetworkConfig) {
        let apiUrl = networkConfig.workfinderApiV3Url
        self.picklistType = picklistType
        self.apiUrl = apiUrl
        url = URL(string: picklistType.endpoint, relativeTo: apiUrl)!
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
                    let results = responseJson.results.count > 0 ? responseJson.results : [
                        PicklistItemJson(uuid: UUID().uuidString, value: "Hard coded value 1"),
                        PicklistItemJson(uuid: UUID().uuidString, value: "Hard coded value 2"),
                        PicklistItemJson(uuid: UUID().uuidString, value: "Hard coded value 3")
                    ]
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

