//
//  AppInstallationLogic.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 20/07/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

public class AppInstallationUuidLogic {
    
    let localStore: LocalStorageProtocol
    
    var installationUuid: F4SUUID? {
        return localStore.value(key: LocalStore.Key.installationUuid) as? F4SUUID
    }
    
    public init(localStore: LocalStorageProtocol = LocalStore()) {
        self.localStore = localStore
    }
    
    public func makeNewInstallationUuid() -> F4SUUID {
        let uuid = UUID().uuidString
        localStore.setValue(uuid, for: LocalStore.Key.installationUuid)
        return uuid
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
    
    public func onInstallationUuidWasRegisteredWithServer(_ uuid: F4SUUID) {
        localStore.setValue(uuid, for: LocalStore.Key.installationUuid)
        localStore.setValue(true, for: LocalStore.Key.isDeviceRegistered)
    }
}
