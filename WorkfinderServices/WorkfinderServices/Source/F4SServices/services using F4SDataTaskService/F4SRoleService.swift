import Foundation
import WorkfinderCommon

public class F4SRoleService: F4SRoleServiceProtocol {
    
    private var dataTask: F4SNetworkTask?
    
    var networkTaskFactory: F4SNetworkTaskFactoryProtocol
    var session: F4SNetworkSession
    let configuration: NetworkConfig
    
    public init(configuration: NetworkConfig) {
        self.configuration = configuration
        self.session = configuration.sessionManager.interactiveSession
        self.networkTaskFactory = F4SNetworkTaskFactory(configuration: configuration)
    }
    
    public func getRoleForCompany(companyUuid: F4SUUID, roleUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SRoleJson>) -> ()) {
        let attempting = "Get role"
        var url = URL(string: configuration.endpoints.roleUrl)!
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
