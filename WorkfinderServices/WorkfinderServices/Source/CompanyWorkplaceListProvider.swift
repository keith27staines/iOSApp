import WorkfinderCommon

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
        completion?(result)
//        guard let completion = completion else { return }
//        deserialise(dataResult: result, completion: completion)
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

