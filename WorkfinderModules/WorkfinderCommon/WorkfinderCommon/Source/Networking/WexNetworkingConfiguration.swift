//
//  NetworkingConfiguration.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 10/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

public protocol WEXNetworkingConfigurationProtocol {
    /// The key for the Workfinder (wex) api
    var wexApiKey: String { get }
    /// The full url of workfinder
    var baseUrlString: String { get }
    /// The full url of the Workfinder v1 api
    var v1ApiUrlString: String { get }
    /// The full url of the Workfinder v2 api
    var v2ApiUrlString: String { get }
}

public struct WEXNetworkingConfiguration : WEXNetworkingConfigurationProtocol {
    public var wexApiKey: String
    public var baseUrlString: String
    public var v1ApiUrlString: String
    public var v2ApiUrlString: String
    
    public init(
        wexApiKey: String,
        baseUrlString: String,
        v1ApiUrlString: String,
        v2ApiUrlString: String) {
        self.wexApiKey = wexApiKey
        self.baseUrlString = baseUrlString
        self.v1ApiUrlString = v1ApiUrlString
        self.v2ApiUrlString = v2ApiUrlString
    }
}

