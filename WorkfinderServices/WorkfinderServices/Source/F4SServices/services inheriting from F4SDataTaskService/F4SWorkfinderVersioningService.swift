
import WorkfinderCommon

public class F4SWorkfinderVersioningService: F4SDataTaskService, F4SWorkfinderVersioningServiceProtocol {
    public init(configuration: NetworkConfig) {
        super.init(baseURLString: configuration.workfinderApi,
                   apiName: "validation/ios-version",
                   configuration: configuration)
    }
    
    public func getIsVersionValid(version: String, completion: @escaping (F4SNetworkResult<F4SVersionValidity>) -> ()) {
        let postObject = ["version" : version]
        super.beginSendRequest(verb: .post, objectToSend: postObject, attempting: "Check version is valid") { (result) in
            switch result {
                
            case .error(let error):
                let result = F4SNetworkResult<F4SVersionValidity>.error(error)
                completion(result)
            case .success(let data):
                guard let data = data else {
                    let versionIsValid = false
                    let result = F4SNetworkResult<F4SVersionValidity>.success(versionIsValid)
                    completion(result)
                    return
                }
                let versionIsValid = Bool(String(data: data, encoding: .utf8)!) ?? false
                let result = F4SNetworkResult.success(versionIsValid)
                completion(result)
            }
        }
    }
}
