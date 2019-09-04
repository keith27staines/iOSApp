import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public protocol F4SDeviceRegistrationServiceProtocol {
    func registerDeviceWithServer(installationUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SRegisterDeviceResult>) -> ())
}

public class F4SDeviceRegistrationService : F4SDataTaskService {
    
    public init() {
        let apiName = "register"
        super.init(baseURLString: WorkfinderEndpoint.baseUrl2, apiName: apiName)
    }
    
    public func registerDevice(anonymousUser: F4SAnonymousUser, completion: @escaping ((F4SNetworkResult<F4SRegisterDeviceResult>) -> ())) {
        let attempting = "Register device"
        beginSendRequest(verb: .post, objectToSend: anonymousUser, attempting: attempting) { [weak self]
            dataResult in
            self?.processResult(dataResult, attempting: attempting, completion: completion)
        }
    }
}

