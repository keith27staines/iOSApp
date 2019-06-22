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

public struct NetworkConfig {
    public static var workfinderApi: String { return _workfinderBaseApiUrlString }
    public static var workfinderApiV1: String { return "\(_workfinderBaseApiUrlString)/v1" }
    public static var workfinderApiV2: String { return "\(_workfinderBaseApiUrlString)/v2" }
    
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

