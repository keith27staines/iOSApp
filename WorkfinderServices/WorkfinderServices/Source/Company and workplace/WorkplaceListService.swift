import WorkfinderCommon

public class WorkplaceListService: WorkfinderService, WorkplaceListProviderProtocol {
    
    public func fetchWorkplaces(
        locationUuids: [F4SUUID],
        completion: @escaping ((Result<CompanyListJson,Error>) -> Void)) {
        
        do {
            let request = try buildFetchCompanyRequest(locationUuids: locationUuids)
            performTask(
                with: request,
                completion: completion,
                attempting: #function)
        } catch {
            completion(Result<CompanyListJson,Error>.failure(error))
        }
    }
    
    func buildFetchCompanyRequest(locationUuids: [F4SUUID]) throws -> URLRequest {
        let uuidString = makeCommaSeparatedList(uuids: locationUuids)
        return try buildRequest(
            relativePath: "companies/",
            queryItems: [URLQueryItem(name: "locations__uuid__in", value: uuidString)],
            verb: .get)
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

