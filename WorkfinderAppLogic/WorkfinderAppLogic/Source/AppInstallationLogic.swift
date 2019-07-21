//
//  AppInstallationLogic.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 20/07/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public class AppInstallationUuidLogic {
    
    let localStore: LocalStorageProtocol
    let userService: F4SUserServiceProtocol
    let userRepo: F4SUserRepositoryProtocol
    
    var installationUuid: F4SUUID? {
        return localStore.value(key: LocalStore.Key.installationUuid) as? F4SUUID
    }
    
    public init(localStore: LocalStorageProtocol = LocalStore(),
                userService: F4SUserServiceProtocol,
                userRepo: F4SUserRepositoryProtocol) {
        self.localStore = localStore
        self.userService = userService
        self.userRepo = userRepo
    }
    
    func makeNewInstallationUuid() -> F4SUUID {
        let uuid = UUID().uuidString
        localStore.setValue(uuid, for: LocalStore.Key.installationUuid)
        return uuid
    }
    
    var mustRegisterAgain: Bool {
        return true
    }
    
    public var registeredInstallationUuid: F4SUUID? {
        guard
            let _ = localStore.value(key: LocalStore.Key.isDeviceRegistered) as? Bool,
            let registeredDeviceUuid = localStore.value(key: LocalStore.Key.installationUuid) as? F4SUUID
        else {
            return nil
        }
        return registeredDeviceUuid
    }
    
    public func ensureDeviceIsRegistered(completion: @escaping (F4SNetworkResult<F4SRegisterDeviceResult>)->()) {
        if mustRegisterAgain {
            registerDevice(completion: completion)
        } else {
            let userUuid = userRepo.load().uuid!
            let registerResult = F4SRegisterDeviceResult(userUuid: userUuid)
            let result = F4SNetworkResult.success(registerResult)
            completion(result)
        }
    }
    
    func loadUser() -> F4SUserProtocol {
        return userRepo.load()
    }
    
    func saveUser(_ userProtocol: F4SUserProtocol) {
        userRepo.save(user: userProtocol)
    }
    
    var userHasVerifiedEmail: Bool {
        guard let verifiedEmail = localStore.value(key: LocalStore.Key.verifiedEmailKey) as? String else {return false}
        return verifiedEmail.isEmpty == false
    }
    
    private func registerDevice(completion: @escaping (F4SNetworkResult<F4SRegisterDeviceResult>)->()) {
        let newInstallationUuid = makeNewInstallationUuid()
        userService.registerDeviceWithServer(installationUuid: newInstallationUuid) { [weak self] (networkResult) in
            guard let strongSelf = self else { return }
            switch networkResult {
            case .error(_):
                completion(networkResult)
            case .success(let registerDeviceResult):
                if let anonymousUserUuid = registerDeviceResult.uuid {
                    strongSelf.onDeviceWasRegisteredOnServer(
                        withInstallationUuid: newInstallationUuid,
                        networkResult: networkResult,
                        completion: completion)
                } else {
                    completion(networkResult)
                }
            }
        }
    }
    
    public func onDeviceWasRegisteredOnServer(
        withInstallationUuid installationUuid: F4SUUID,
        networkResult: F4SNetworkResult<F4SRegisterDeviceResult>,
        completion: @escaping (F4SNetworkResult<F4SRegisterDeviceResult>)->())  {
        localStore.setValue(installationUuid, for: LocalStore.Key.installationUuid)
        localStore.setValue(true, for: LocalStore.Key.isDeviceRegistered)
        if userHasVerifiedEmail {
            let userInfo = F4SUserInformation()
            var oldUser = userRepo.load()
            let user = F4SUser(userInformation: userInfo)
            user.email = oldUser.email
            user.requiresConsent = oldUser.requiresConsent
            user.termsAgreed = oldUser.termsAgreed
            userService.updateUser(user: user) { [weak self] updateUserResult in
                guard let strongSelf = self else { return }
                switch updateUserResult {
                case .error(_):
                    break
                case .success(let userUpdateResult):
                    var user = strongSelf.userRepo.load()
                    user.updateUuid(uuid: userUpdateResult.uuid!)
                    strongSelf.userRepo.save(user: user)
                    let updatedResult = F4SNetworkResult.success(F4SRegisterDeviceResult.init(userUuid: user.uuid!))
                    completion(updatedResult)
                }
            }
        } else {
            completion(networkResult)
        }
    }
}
