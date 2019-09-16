import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public class F4SDeviceRegistrationService : F4SDataTaskService, F4SDeviceRegistrationServiceProtocol {
    
    public init(configuration: NetworkConfig) {
        let apiName = "register"
        super.init(baseURLString: configuration.endpoints.baseUrl2,
                   apiName: apiName,
                   configuration: configuration)
    }
    
    public func registerDevice(anonymousUser: F4SAnonymousUser, completion: @escaping ((F4SNetworkResult<F4SRegisterDeviceResult>) -> ())) {
        let attempting = "Register device"
        beginSendRequest(verb: .post, objectToSend: anonymousUser, attempting: attempting) { [weak self]
            dataResult in
            self?.processResult(dataResult, attempting: attempting, completion: completion)
        }
    }
}

