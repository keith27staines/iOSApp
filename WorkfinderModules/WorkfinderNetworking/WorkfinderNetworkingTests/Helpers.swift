//
//  Helpers.swift
//  WorkfinderNetworkingTests
//
//  Created by Keith Dev on 10/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import WorkfinderCommon

func makeNetworkConfiguration(
    wexApiKey: String = "api",
    baseUrlString: String = "baseUrl",
    v1ApiUrlString: String = "v1Url",
    v2ApiUrlString: String = "v2Url") -> WEXNetworkingConfigurationProtocol {
    let config: WEXNetworkingConfigurationProtocol = WEXNetworkingConfiguration(
        wexApiKey: wexApiKey,
        baseUrlString: baseUrlString,
        v1ApiUrlString: v1ApiUrlString,
        v2ApiUrlString: v2ApiUrlString)
    return config
}

