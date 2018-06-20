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
    func updateUser(user: F4SUser, completion: @escaping (F4SNetworkResult<F4SJSONValue>) -> Void)
    func enablePushNotificationForUser(withDeviceToken: String, completion: @escaping (_ result: F4SNetworkResult<F4SJSONValue>) -> Void)
}

public struct F4SUserModel : Decodable {
    public var uuid: F4SUUID?
    public var errors: F4SJSONValue?
    public init(uuid: F4SUUID? = nil, errors: F4SJSONValue? = nil) {
        self.uuid = uuid
        self.errors = errors
    }
}

public class F4SUserService : F4SUserServiceProtocol {
    
    public var vendorID: String { return UIDevice.current.identifierForVendor!.uuidString }
    
    public func hasAccount() -> Bool {
        return UserDefaults.standard.object(forKey: UserDefaultsKeys.userHasAccount) != nil && UserDefaults.standard.bool(forKey: UserDefaultsKeys.userHasAccount)
    }
    
    public func registerAnonymousUserOnServer(completion: @escaping (F4SUUID?) -> Void) {
        let attempting = "Register anonymous user on server"
        let url = URL(string: ApiConstants.userProfileUrl)!
        let session = F4SNetworkSessionManager.shared.interactiveSession
        var urlRequest = F4SDataTaskService.urlRequest(verb: .post, url: url, dataToSend: nil)
        urlRequest.addValue(vendorID, forHTTPHeaderField: "vendor_uuid")
        urlRequest.addValue("ios", forHTTPHeaderField: "type")
        urlRequest.addValue(Config.apnsEnv, forHTTPHeaderField: "env")
        let dataTask = F4SDataTaskService.dataTask(with: urlRequest, session: session, attempting: attempting) { (result) in
            let decoder = JSONDecoder()
            decoder.decode(dataResult: result, intoType: F4SUserModel.self, attempting: attempting, completion: { result in
                switch result {
                case .error(let error):
                    log.debug("Failed to register anonymous user with error \(error)")
                    completion(nil)
                case .success(let userModel):
                    guard let userUuid = userModel.uuid else {
                        log.debug("Failed to register anonymous user because although the server request succeeded, the server did not provide a user uuid")
                        completion(nil)
                        return
                    }
                    log.debug("user created ok. Profile uuid from wex is: \(userUuid)")
                    let keychain = KeychainSwift()
                    keychain.set(userUuid, forKey: UserDefaultsKeys.userUuid)
                    UserDefaults.standard.set(true, forKey: UserDefaultsKeys.userHasAccount)
                    completion(result)
                }
            })
        }
        dataTask.resume()
    }
    
    public func updateUser(user: F4SUser, completion: @escaping (F4SNetworkResult<F4SJSONValue>) -> Void) {
        
    }
    
    public func enablePushNotificationForUser(withDeviceToken: String, completion: @escaping (F4SNetworkResult<F4SJSONValue>) -> Void) {
        
    }
    
    
}
