//
//  WorkfinderNetworking.swift
//  WorkfinderNetworking
//
//  Created by Keith Dev on 09/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import WorkfinderCommon

var sharedSessionManager: WEXSessionManager!

public func configure(configuration: WEXNetworkingConfigurationProtocol) throws {
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
