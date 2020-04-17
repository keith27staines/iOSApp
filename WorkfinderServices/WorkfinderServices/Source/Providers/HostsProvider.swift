
import WorkfinderCommon

public protocol HostsProviderProtocol {
    func fetchHosts(locationUuid: F4SUUID, completion: @escaping((Result<HostListJson,Error>) -> Void) )
}

public class HostsProvider: WorkfinderService, HostsProviderProtocol {
    
    var completion: ((Result<HostListJson,Error>) -> Void)?
    
    public func fetchHosts(locationUuid: F4SUUID, completion: @escaping((Result<HostListJson,Error>) -> Void) ) {
        let request = buildRequest(locationUuid: locationUuid, urlComponents: urlComponents)
        task?.cancel()
        self.completion = completion
        task = session.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            guard let self = self else { return }
            self.taskHandler.convertToDataResult(data: data, response: response, error: error, completion: self.deserializeDataResult)
            
        })
        task?.resume()
    }
    
    func deserializeDataResult(_ result: Result<Data,Error>) {
        guard let completion = completion else { return }
        deserialise(dataResult: result, completion: completion)
    }
    
    func buildRequest(locationUuid: F4SUUID, urlComponents: URLComponents) -> URLRequest {
        var components = urlComponents
        components.path = urlComponents.path + "hosts/"
        components.queryItems = [URLQueryItem(name: "location", value: locationUuid)]
        let url = components.url!
        return networkConfig.buildUrlRequest(url: url, verb: .get, body: nil)
    }
}

