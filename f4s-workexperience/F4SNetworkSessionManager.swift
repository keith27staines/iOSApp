//
//  F4SNetworkSessionManager.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 17/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
import KeychainSwift

public class F4SNetworkSessionManager {
    public static let shared = F4SNetworkSessionManager()
    
    internal init() {}
    
    public internal (set) lazy var interactiveSession: URLSession = {
        return URLSession(configuration: interactiveConfiguration)
    }()
    
    public internal (set) lazy var smallImageSession: URLSession = {
        return URLSession(configuration: smallImageConfiguration)
    }()
    
    public internal (set) lazy var firstRegistrationSession: URLSession = {
        return URLSession(configuration: firstRegistrationConfiguration)
    }()
    
    // MARK:- Internal properties
    internal lazy var defaultHeaders : [String:String] = {
        var header: [String : String] = ["wex.api.key": ApiConstants.apiKey]
        let keychain = KeychainSwift()
        if let userUuid = keychain.get(UserDefaultsKeys.userUuid) {
            header["wex.user.uuid"] = userUuid
        } else {
            log.debug("Default headers called but user.uuid is not available")
            assertionFailure("This method should only be called if a userUuid exists")
        }
        return header
    }()
    
    internal lazy var firstRegistrationHeaders : [String : String] = {
        return ["wex.api.key": ApiConstants.apiKey]
    }()
    
    internal lazy var firstRegistrationConfiguration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = firstRegistrationHeaders
        configuration.allowsCellularAccess = true
        return configuration
    }()
    
    internal lazy var interactiveConfiguration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = defaultHeaders
        configuration.allowsCellularAccess = true
        return configuration
    }()
    
    internal lazy var smallImageConfiguration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.allowsCellularAccess = true
        let memory = 5 * 1024 * 1024
        let disk = 10 * memory
        let name = "smallImageCache"
        let cache = URLCache(memoryCapacity: memory, diskCapacity: disk, diskPath: name)
        configuration.urlCache = cache
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return configuration
    }()
}

















