import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public class F4SUserService : F4SUserServiceProtocol {
    
    let configuration: NetworkConfig
    let factory: F4SNetworkTaskFactory
    
    public init(configuration: NetworkConfig) {
        self.configuration = configuration
        self.factory = F4SNetworkTaskFactory(configuration: configuration)
    }
    
    lazy var dobFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy'-'MM'-'dd"
        return df
    }()
    
    public func updateUser(user: F4SUser, completion: @escaping (F4SNetworkResult<F4SUserModel>) -> ()) {
        var user = user
        user.uuid = nil
        let attempting = "Update user"
        let url = URL(string: configuration.endpoints.updateUserProfileUrl)!
        let session = configuration.sessionManager.interactiveSession
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .formatted(dobFormatter)
            let data = try encoder.encode(user)
            let dataTask = factory.networkTask(verb: .patch, url: url, dataToSend: data, attempting: attempting, session: session) { [weak self] (result) in
                self?.handleUpdateUserTaskResult(attempting: attempting, result: result, completion: completion)
            
            }
            dataTask.resume()
        } catch {
            let serializationError = F4SNetworkDataErrorType.serialization(user).error(attempting: attempting)
            completion(F4SNetworkResult.error(serializationError))
        }
    }
    
    private func handleUpdateUserTaskResult(attempting: String, result: F4SNetworkDataResult, completion: @escaping (F4SNetworkResult<F4SUserModel>) -> ()) {
        DispatchQueue.main.async {
            let decoder = JSONDecoder()
            decoder.decode(dataResult: result, intoType: F4SUserModel.self, attempting: attempting, completion: completion)
        }
    }
    
    public func enablePushNotificationForUser(installationUuid: F4SUUID, withDeviceToken: String, completion: @escaping (F4SNetworkResult<F4SPushNotificationStatus>) -> Void) {
        let attempting = "Enable push notification on server"
        let url = URL(string: configuration.endpoints.registerPushNotifictionToken + "/\(installationUuid)")!
        let session = configuration.sessionManager.interactiveSession
        let pushToken = F4SPushToken(pushToken: withDeviceToken)
        let encoder = JSONEncoder()
        let data: Data
        do {
            data = try encoder.encode(pushToken)
        } catch {
            let serializationError = F4SNetworkDataErrorType.serialization(pushToken).error(attempting: attempting)
            completion(F4SNetworkResult.error(serializationError))
            return
        }
        let dataTask = factory.networkTask(verb: .put, url: url, dataToSend: data, attempting: attempting, session: session) { [weak self] (result) in
            self?.handleEnableNotificatioTaskResult(attempting: attempting, result: result, completion: completion)
        }
        dataTask.resume()
    }
    
    private func handleEnableNotificatioTaskResult(attempting: String, result: F4SNetworkDataResult, completion: @escaping (F4SNetworkResult<F4SPushNotificationStatus>) -> ()) {
        DispatchQueue.main.async {
            switch result {
            case .error(let error):
                completion(F4SNetworkResult.error(error))
            case .success(_):
                let decoder = JSONDecoder()
                decoder.decode(dataResult: result, intoType: F4SPushNotificationStatus.self, attempting: attempting, completion: { result in
                    switch result {
                    case .error(let error):
                        completion(F4SNetworkResult.error(error))
                    case .success(let pushStatus):
                        guard pushStatus.enabled != nil else {
                            let serverError = F4SNetworkDataErrorType.unknownError(pushStatus).error(attempting: attempting)
                            completion(F4SNetworkResult.error(serverError))
                            return
                        }
                        completion(F4SNetworkResult.success(pushStatus))
                    }
                })
            }
        }
    }
}
