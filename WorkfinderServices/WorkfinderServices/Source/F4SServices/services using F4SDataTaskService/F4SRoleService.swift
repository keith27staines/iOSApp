import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public class F4SRoleService {
    
    private var dataTask: F4SNetworkTask?
    
    var networkTaskFactory: F4SNetworkTaskFactoryProtocol = F4SNetworkTaskFactory()
    var sessionManager: F4SNetworkSessionManagerProtocol
    var session: F4SNetworkSession { return sessionManager.interactiveSession}
    
    public init(sessionManager: F4SNetworkSessionManagerProtocol = F4SNetworkSessionManager.shared) {
        self.sessionManager = sessionManager
    }
    
    public func getRoleForCompany(companyUuid: F4SUUID, roleUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SRoleJson>) -> ()) {
        let attempting = "Get role"
        var url = URL(string: WorkfinderEndpoint.roleUrl)!
        url.appendPathComponent(companyUuid)
        url.appendPathComponent("roles")
        url.appendPathComponent(roleUuid)
        dataTask?.cancel()
        dataTask = networkTaskFactory.networkTask(verb: .get, url: url, dataToSend: nil, attempting: attempting, session: session) { (result) in
            switch result {
            case .error(let error):
                completion(F4SNetworkResult.error(error))
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.decode(data: data, intoType: F4SRoleJson.self, attempting: attempting, completion: completion)
            }
        }
        dataTask?.resume()
    }
}
