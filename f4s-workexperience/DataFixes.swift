//
//  DataFixes.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 28/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import CoreData
import WorkfinderCommon
import WorkfinderApplyUseCase
import WorkfinderOnboardingUseCase
import KeychainSwift

public struct DataFixes {
    
    public func run() {
        deleteV2KeysIfNecessary()
        updateVersion()
    }
    
    func updateVersion() {
        let defaults = UserDefaults.standard
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!
        defaults.setValue(version, for: LocalStore.Key.appVersion)
    }
    
    func deleteV2KeysIfNecessary() {
        let defaults = UserDefaults.standard
        guard defaults.value(key: LocalStore.Key.appVersion) == nil else { return }
        defaults.dictionaryRepresentation().forEach { (item) in
            defaults.removeObject(forKey: item.key)
        }
        KeychainSwift().clear()
    }
    
}

