//
//  F4SUserService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 19/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
import KeychainSwift

public protocol F4SUserServiceProtocol {
    var vendorID: String { get }
    func hasAccount() -> Bool
    func registerAnonymousUserOnServer(completion: @escaping (F4SUUID?) -> Void)
    func updateUser(user: F4SUser, completion: @escaping (F4SNetworkResult<F4SUserModel>) -> Void)
    func enablePushNotificationForUser(withDeviceToken: String, completion: @escaping (_ result: F4SNetworkResult<F4SJSONValue>) -> Void)
}

public class F4SUserService : F4SUserServiceProtocol {
    
    public var vendorID: String { return UIDevice.current.identifierForVendor!.uuidString }
    
    public func hasAccount() -> Bool {
        return UserDefaults.standard.object(forKey: UserDefaultsKeys.userHasAccount) != nil && UserDefaults.standard.bool(forKey: UserDefaultsKeys.userHasAccount)
    }
    
    public func updateUser(user: F4SUser, completion: @escaping (F4SNetworkResult<F4SUserModel>) -> Void) {
        let attempting = "Update user"
        let keychain = KeychainSwift()
        var currentUserUuid: String = ""
        if let userUuid = keychain.get(UserDefaultsKeys.userUuid) {
            currentUserUuid = userUuid
        }
        
        let url = URL(string: ApiConstants.updateUserProfileUrl + currentUserUuid)!
        
        let session = F4SNetworkSessionManager.shared.interactiveSession
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(user)
            let urlRequest = F4SDataTaskService.urlRequest(verb: .put, url: url, dataToSend: data)
            let dataTask = F4SDataTaskService.dataTask(with: urlRequest, session: session, attempting: attempting) { (result) in
                let decoder = JSONDecoder()
                decoder.decode(dataResult: result, intoType: F4SUserModel.self, attempting: attempting, completion: { result in
                    switch result {
                    case .error(let error):
                        completion(F4SNetworkResult.error(error))
                    case .success(let userModel):
                        guard let userUuid = userModel.uuid else {
                            log.debug("Failed to update user")
                            let unknownError = F4SNetworkDataErrorType.unknownError(userModel).error(attempting: attempting)
                            completion(F4SNetworkResult.error(unknownError))
                            return
                        }
                        let keychain = KeychainSwift()
                        keychain.set(userUuid, forKey: UserDefaultsKeys.userUuid)
                        completion(F4SNetworkResult.success(userModel))
                    }
                })
            }
            dataTask.resume()
        } catch {
            let serializationError = F4SNetworkDataErrorType.serialization(user).error(attempting: attempting)
            completion(F4SNetworkResult.error(serializationError))
        }
    }
    
    public func registerAnonymousUserOnServer(completion: @escaping (F4SUUID?) -> Void) {
        let attempting = "Register anonymous user on server"
        let url = URL(string: ApiConstants.userProfileUrl)!
        let session = F4SNetworkSessionManager.shared.interactiveSession
        let anonymousUser = F4SAnonymousUser(vendorUuid: vendorID, type: "ios", env: Config.apnsEnv)
        let encoder = JSONEncoder()
        let data: Data
        do {
            data = try encoder.encode(anonymousUser)
        } catch {
            completion(nil)
            return
        }
        
        let urlRequest = F4SDataTaskService.urlRequest(verb: .post, url: url, dataToSend: data)
        let dataTask = F4SDataTaskService.dataTask(with: urlRequest, session: session, attempting: attempting) { (result) in
            switch result {
            case .error(_):
                completion(nil)
            case .success(_):
                let decoder = JSONDecoder()
                decoder.decode(dataResult: result, intoType: F4SUserModel.self, attempting: attempting, completion: { result in
                    switch result {
                    case .error(let error):
                        log.debug("Error registering anonymous user: \(error)")
                        completion(nil)
                    case .success(let userModel):
                        guard let userUuid = userModel.uuid else {
                            log.debug("Failed to register anonymous user because although the server request appears to have succeeded, the server did not provide a user uuid")
                            completion(nil)
                            return
                        }
                        log.debug("user created with uuid \(userUuid)")
                        let keychain = KeychainSwift()
                        keychain.set(userUuid, forKey: UserDefaultsKeys.userUuid)
                        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.userHasAccount)
                        completion(userUuid)
                    }
                })
            }
        }
        dataTask.resume()
    }
    
    public func enablePushNotificationForUser(withDeviceToken: String, completion: @escaping (F4SNetworkResult<F4SJSONValue>) -> Void) {
        
    }
    
    
}
