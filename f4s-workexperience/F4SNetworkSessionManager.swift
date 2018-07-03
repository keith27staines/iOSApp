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
    
    internal var _interactiveSession: URLSession?
    internal var _smallImageSession: URLSession?
    internal var _firstRegistrationSession: URLSession?
    
    internal init() {}
    
    public var interactiveSession: URLSession {
        if _interactiveSession == nil {
            _interactiveSession = URLSession(configuration: interactiveConfiguration)
        }
        return _interactiveSession!
    }
    
    public var smallImageSession: URLSession {
        if _smallImageSession == nil {
            _smallImageSession = URLSession(configuration: smallImageConfiguration)
        }
        return _smallImageSession!
    }
    
    public var firstRegistrationSession: URLSession {
        if _firstRegistrationSession == nil {
            _firstRegistrationSession = URLSession(configuration: firstRegistrationConfiguration)
        }
        return _firstRegistrationSession!
    }
    
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
    
    public func rebuildSessions() {
        _interactiveSession = nil
        _smallImageSession = nil
        _firstRegistrationSession = nil
    }
    
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

















