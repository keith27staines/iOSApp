//
//  F4SUserService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 19/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public class F4SUserService : F4SUserServiceProtocol {
    
    lazy var dobFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy'-'MM'-'dd"
        return df
    }()
    
    public func updateUser(user: F4SUser, completion: @escaping (F4SNetworkResult<F4SUserModel>) -> ()) {
        var user = userRemovingInvalidPartnersFromUserDataFix(user: user)
        user = userNullifyingUuid(user: user)
        let attempting = "Update user"
        if let age = user.age() { user.requiresConsent = age < 16 }
        if user.parentEmail?.isEmpty == true { user.parentEmail = nil }
        let url = URL(string: WorkfinderEndpoint.updateUserProfileUrl)!
        let session = F4SNetworkSessionManager.shared.interactiveSession
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .formatted(dobFormatter)
            let data = try encoder.encode(user)
            let urlRequest = F4SDataTaskService.urlRequest(verb: .patch, url: url, dataToSend: data)
            let dataTask = F4SDataTaskService.networkTask(with: urlRequest, session: session, attempting: attempting) { [weak self] (result) in
                
                self?.handleUpdateUserTaskResult(attempting: attempting, result: result, completion: completion)
            
            }
            dataTask.resume()
        } catch {
            let serializationError = F4SNetworkDataErrorType.serialization(user).error(attempting: attempting)
            completion(F4SNetworkResult.error(serializationError))
        }
    }
    
    /// If the user's partner (referrer) uuid isn't in one of the known good uuids
    /// (currently "kown good" uuids are those in a hard coded list in
    /// F4SPartnersModel) then the partner should be deleted
    func userRemovingInvalidPartnersFromUserDataFix(user: F4SUser) -> F4SUser {
        guard let partnerUuid = user.partners?.first else { return user }
        if !F4SPartnersModel.hardCodedPartners().contains(where: { (partner) -> Bool in
            partner.uuid == partnerUuid.uuid
        }) {
            user.partners = nil
            return user
        }
        return user
    }
    
    func userNullifyingUuid(user: F4SUser) -> F4SUser {
        let user = F4SUser(userInformation: user)
        user.nullifyUuid()
        return user
    }
    
    private func handleUpdateUserTaskResult(attempting: String, result: F4SNetworkDataResult, completion: @escaping (F4SNetworkResult<F4SUserModel>) -> ()) {
        DispatchQueue.main.async {
            let decoder = JSONDecoder()
            decoder.decode(dataResult: result, intoType: F4SUserModel.self, attempting: attempting, completion: completion)
        }
    }
    
    public func registerDeviceWithServer(installationUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SRegisterDeviceResult>) -> Void) {
        let attempting = "Register anonymous user on server"
        let url = URL(string: WorkfinderEndpoint.registerVendorId)!
        let session = F4SNetworkSessionManager.shared.interactiveSession
        let anonymousUser = F4SAnonymousUser(vendorUuid: installationUuid, clientType: "ios", apnsEnvironment: Config.apnsEnv)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data: Data
        do {
            data = try encoder.encode(anonymousUser)
        } catch {
            let serializationError = F4SNetworkDataErrorType.serialization(anonymousUser).error(attempting: attempting)
            completion(F4SNetworkResult.error(serializationError))
            return
        }
        
        let urlRequest = F4SDataTaskService.urlRequest(verb: .post, url: url, dataToSend: data)
        let dataTask = F4SDataTaskService.networkTask(with: urlRequest, session: session, attempting: attempting) { [weak self] (result) in
            self?.handleRegisterAnonymousUserTaskResult(attempting: attempting, result: result, completion: completion)
        }
        dataTask.resume()
    }
    
    private func handleRegisterAnonymousUserTaskResult(attempting: String, result: F4SNetworkDataResult, completion: @escaping (F4SNetworkResult<F4SRegisterDeviceResult>) -> ()) {
        DispatchQueue.main.async {
            let decoder = JSONDecoder()
            decoder.decode(dataResult: result, intoType: F4SRegisterDeviceResult.self, attempting: attempting, completion: completion)
        }
    }
    
    public func enablePushNotificationForUser(installationUuid: F4SUUID, withDeviceToken: String, completion: @escaping (F4SNetworkResult<F4SPushNotificationStatus>) -> Void) {
        let attempting = "Enable push notification on server"
        let url = URL(string: WorkfinderEndpoint.registerPushNotifictionToken + "/\(installationUuid)")!
        let session = F4SNetworkSessionManager.shared.interactiveSession
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
        
        let urlRequest = F4SDataTaskService.urlRequest(verb: .put, url: url, dataToSend: data)
        let dataTask = F4SDataTaskService.networkTask(with: urlRequest, session: session, attempting: attempting) { [weak self] (result) in
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
