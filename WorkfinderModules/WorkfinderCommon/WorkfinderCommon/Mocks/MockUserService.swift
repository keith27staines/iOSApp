
import Foundation

class MockUserService: F4SUserServiceProtocol {
    func registerDeviceWithServer(installationUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SRegisterDeviceResult>) -> ()) {
        registerDeviceOnServerCalled += 1
        let result: F4SNetworkResult<F4SRegisterDeviceResult>
        if registerDeviceOnServerCalled == registeringWillSucceedOnAttempt {
            result = F4SNetworkResult.success(successRegisterResult)
        } else {
            result = F4SNetworkResult.error(error)
        }
        completion(result)
    }
    
    
    var registerDeviceOnServerCalled: Int = 0
    var registeringWillSucceedOnAttempt: Int = 0
    var successRegisterResult = F4SRegisterDeviceResult(userUuid: UUID().uuidString)
    var errorResult = F4SRegisterDeviceResult(errors: F4SJSONValue(integerLiteral: 999))
    var error = F4SNetworkError(localizedDescription: "Error handling test", attempting: "test", retry: false, logError: false)
    
    init(registeringWillSucceedOnAttempt: Int) {
        self.registeringWillSucceedOnAttempt = registeringWillSucceedOnAttempt
    }
    
    func enablePushNotificationForUser(installationUuid: F4SUUID, withDeviceToken: String, completion: @escaping (F4SNetworkResult<F4SPushNotificationStatus>) -> ()) {
        
    }
    
    func updateUser(user: Candidate, completion: @escaping (F4SNetworkResult<F4SUserModel>) -> ()) {
        fatalError()
    }
    
    func enablePushNotificationForUser(withDeviceToken: String, completion: @escaping (F4SNetworkResult<F4SPushNotificationStatus>) -> ()) {
        fatalError()
    }
    
}
