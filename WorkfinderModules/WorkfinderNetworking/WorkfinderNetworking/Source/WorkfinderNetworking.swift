//
//  WorkfinderNetworking.swift
//  WorkfinderNetworking
//
//  Created by Keith Dev on 09/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

var sharedSessionManager: WEXSessionManager!

func configure(configuration: WexNetworkingConfigurationProtocol) throws {
    guard sharedSessionManager == nil else { throw WorkfinderNetworkingError.SessionManagerMayOnlyBeConfiguredOnce}
    sharedSessionManager = WEXSessionManager(configuration: configuration)
}

public enum WorkfinderNetworkingError : Error {
    case SessionManagerMayOnlyBeConfiguredOnce
}

public class WorkfinderNetworking {
    public init(){}
    public func sayHello(to name: String) -> String {
        return "Hello \(name) from WorkfinderNetworking"
    }
}
