import WorkfinderCommon

public protocol F4SUserServiceProtocol : class {
    func registerDeviceWithServer(installationUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SRegisterDeviceResult>) -> ())
    func updateUser(user: F4SUser, completion: @escaping (F4SNetworkResult<F4SUserModel>) -> ())
    func enablePushNotificationForUser(installationUuid: F4SUUID, withDeviceToken: String, completion: @escaping (_ result: F4SNetworkResult<F4SPushNotificationStatus>) -> ())
}
