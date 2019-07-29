//
//  AppInstallationLogic.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 20/07/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderServices

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
        return registeredInstallationUuid == nil  || !userHasVerifiedEmail
    }
    
    public var registeredInstallationUuid: F4SUUID? {
        guard
            let _ = localStore.value(key: LocalStore.Key.isDeviceRegistered) as? Bool,
            let registeredDeviceUuid = installationUuid
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
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                switch networkResult {
                case .error(_):
                    completion(networkResult)
                case .success(let registerDeviceResult):
                    if let _ = registerDeviceResult.uuid {
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
    }
    
    func onDeviceWasRegisteredOnServer(
        withInstallationUuid installationUuid: F4SUUID,
        networkResult: F4SNetworkResult<F4SRegisterDeviceResult>,
        completion: @escaping (F4SNetworkResult<F4SRegisterDeviceResult>)->())  {

        if userHasVerifiedEmail {
            let userInfo = F4SUserInformation()
            var oldUser = userRepo.load()
            let user = F4SUser(userInformation: userInfo)
            user.email = oldUser.email
            user.requiresConsent = oldUser.requiresConsent
            user.termsAgreed = oldUser.termsAgreed
            userService.updateUser(user: user) { updateUserResult in
                DispatchQueue.main.async {  [weak self] in
                    guard let strongSelf = self else { return }
                    switch updateUserResult {
                    case .error(let networkError):
                        let updatedResult = F4SNetworkResult<F4SRegisterDeviceResult>.error(networkError)
                        completion(updatedResult)
                    case .success(let userUpdateResult):
                        var user = strongSelf.userRepo.load()
                        user.updateUuid(uuid: userUpdateResult.uuid!)
                        strongSelf.userRepo.save(user: user)
                        strongSelf.localStore.setValue(installationUuid, for: LocalStore.Key.installationUuid)
                        strongSelf.localStore.setValue(true, for: LocalStore.Key.isDeviceRegistered)
                        let updatedResult = F4SNetworkResult.success(F4SRegisterDeviceResult.init(userUuid: user.uuid!))
                        completion(updatedResult)
                    }
                }
            }
        } else {
            localStore.setValue(installationUuid, for: LocalStore.Key.installationUuid)
            localStore.setValue(true, for: LocalStore.Key.isDeviceRegistered)
            completion(networkResult)
        }
    }
}
