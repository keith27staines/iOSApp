//
//  NetworkConfig.swift
//  WorkfinderNetworking
//
//  Created by Keith Dev on 19/06/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation


public struct NetworkConfig {
    #if STAGING
    
    // Development & testing config
    
    public static let ENVIRONMENT = "STAGING"
    public static let BASE = "https://staging.workfinder.com/api"
    public static let BASE_URL = "https://staging.workfinder.com/api/v1"
    public static let BASE_URL2 = "https://staging.workfinder.com/api/v2"
    
    #else
    
    // Default to production (live) config
    
    public static let ENVIRONMENT = "PRODUCTION"
    public static let BASE = "https://www.workfinder.com/api"
    public static let BASE_URL = "https://www.workfinder.com/api/v1"
    public static let BASE_URL2 = "https://www.workfinder.com/api/v2"
    
    
    #endif
}

