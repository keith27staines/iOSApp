
import WorkfinderCommon

public protocol HostsProviderProtocol {
    func fetchHosts(locationUuid: F4SUUID, completion: @escaping((Result<[Host],Error>) -> Void) )
}

public class HostsProvider: HostsProviderProtocol {
    let taskHandler = TaskCompletionHandler()
    let endpoint: String
    let session = URLSession(configuration: URLSessionConfiguration.default)
    var task: URLSessionDataTask?
    
    public init(apiUrlString: String) {
        // /v3/hosts/?associations__location__uuid=<location-uuid>
        self.endpoint = apiUrlString + "hosts/"
    }
    
    var completion: ((Result<[Host],Error>) -> Void)?
    
    public func fetchHosts(locationUuid: F4SUUID, completion: @escaping((Result<[Host],Error>) -> Void) ) {
        let request = makeURLRequest(locationUuid: locationUuid)
        task?.cancel()
        self.completion = completion
        task = session.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            guard let self = self else { return }
            self.taskHandler.handleResult(data: data, response: response, error: error, completion: self.deserialise)
            
        })
        task?.resume()
    }
    
    func deserialise(dataResult: Result<Data,Error>) {
        switch dataResult {
        case .success(let data):
            do {
                let hostsListJson = try JSONDecoder().decode(HostListJson.self, from: data)
                completion?(Result<[Host],Error>.success(hostsListJson.results ?? []))
            } catch {
                completion?(Result<[Host],Error>.failure(NetworkError.deserialization(error)))
            }
        case .failure(let error):
            completion?(Result<[Host],Error>.failure(error))
        }
    }
    
    func makeURLRequest(locationUuid: F4SUUID) -> URLRequest {
        var components = URLComponents(string: endpoint)!
        components.queryItems = [URLQueryItem(name: "location", value: locationUuid)]
        let url = components.url!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
}

