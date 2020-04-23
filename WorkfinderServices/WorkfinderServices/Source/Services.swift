
import WorkfinderCommon

public class PicklistProvider: PicklistProviderProtocol {
    
    public let picklistType: PicklistType
    public var moreToCome: Bool = false
    let apiUrl: String = "http://workfinder-develop.eu-west-2.elasticbeanstalk.com/v3/"
    let urlString: String
    let urlRequest: URLRequest
    var completionHandler: ((Result<[PicklistItemJson],Error>) -> Void)?
    let url: URL
    let session: URLSession = URLSession(configuration: URLSessionConfiguration.default)
    var task: URLSessionDataTask?
    
    public init(picklistType: PicklistType) {
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

public class CompanyWorkplaceListProvider: WorkfinderService, CompanyWorkplaceListProviderProtocol {
    
    var completion: ((Result<Data,Error>) -> Void)?
    
    public func fetchCompanyWorkplaces(
        locationUuids: [F4SUUID],
        completion: @escaping ((Result<Data,Error>) -> Void)) {
        self.completion = completion
        task?.cancel()
        task = buildTask(locationUuids: locationUuids)
        task?.resume()
    }
    
    func deserializeDataResult(_ result: Result<Data,Error>) {
        guard let completion = completion else { return }
        deserialise(dataResult: result, completion: completion)
    }
    
    func buildTask(locationUuids: [F4SUUID]) -> URLSessionDataTask {
        task?.cancel()
        let request = buildURLRequest(locationUuids: locationUuids)
        task = session.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            guard let self = self else { return }
            self.taskHandler.convertToDataResult(data: data, response: response, error: error, completion: self.deserializeDataResult)
        })
        return task!
    }
    
    func buildURLRequest(locationUuids: [F4SUUID]) -> URLRequest {
        let relativeString = "companies/"
        let endpoint = URL(string: relativeString, relativeTo: networkConfig.workfinderApiV3Url)!
        var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: true)!
        let uuidString = makeCommaSeparatedList(uuids: locationUuids)
        let queryItem = URLQueryItem(name: "locations__uuid__in", value: uuidString)
        components.queryItems = [queryItem]
        let url = components.url!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
    
    func makeCommaSeparatedList(uuids: [F4SUUID]) -> String {
        var list: String = ""
        for uuid in uuids {
            list.append(uuid)
            list.append(",")
        }
        list.removeLast()
        return list
    }
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

