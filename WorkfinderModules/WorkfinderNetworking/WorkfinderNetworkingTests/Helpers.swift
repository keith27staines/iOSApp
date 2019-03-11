//
//  Helpers.swift
//  WorkfinderNetworkingTests
//
//  Created by Keith Dev on 10/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon


func makeNetworkConfiguration() -> WexNetworkingConfigurationProtocol {
    let config: WexNetworkingConfigurationProtocol = WexNetworkingConfiguration(
        wexApiKey: "api",
        baseUrlString: "baseUrl",
        v1ApiUrlString: "v1Url",
        v2ApiUrlString: "v2Url")
    return config
}

