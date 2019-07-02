//
//  NetworkConfig.swift
//  WorkfinderNetworking
//
//  Created by Keith Dev on 19/06/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

private var _workfinderBaseApiUrlString: String = ""

/// Provides a single point to configure the entire networking stack
public struct NetworkConfig {
    
    /// The base url for the workfinder api, excluding v1 or v2 postfixes
    public static var workfinderApi: String { return _workfinderBaseApiUrlString }
    
    /// The full url for the v1 api
    public static var workfinderApiV1: String { return "\(_workfinderBaseApiUrlString)/v1" }
    
    /// The full url for the v2 api
    public static var workfinderApiV2: String { return "\(_workfinderBaseApiUrlString)/v2" }
    
    /// Configures the entire networking stack
    ///
    /// - Parameters:
    ///   - wexApiKey: the api key required for Workfinder api access
    ///   - workfinderBaseApi: The base url for the api, which is supplemented inrterally by v1, v2 etc
    ///   - log: A logging mechanism in which network errors will be reported
    public static func configure(wexApiKey: String, workfinderBaseApi: String, log: F4SAnalyticsAndDebugging) {
        _workfinderBaseApiUrlString = workfinderBaseApi
        let config: WEXNetworkingConfigurationProtocol = WEXNetworkingConfiguration(
            wexApiKey: wexApiKey,
            baseUrlString: NetworkConfig.workfinderApi,
            v1ApiUrlString: NetworkConfig.workfinderApiV1,
            v2ApiUrlString: NetworkConfig.workfinderApiV2)
        F4SNetworkSessionManager.shared = F4SNetworkSessionManager(log: log)
        try? configureWEXSessionManager(configuration: config)
    }
}

