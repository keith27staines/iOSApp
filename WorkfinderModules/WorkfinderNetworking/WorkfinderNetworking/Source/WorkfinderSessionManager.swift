//
//  WorkfinderSessionManager.swift
//  WorkfinderNetworking
//
//  Created by Keith Dev on 10/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import WorkfinderCommon

typealias Headers = [String:String]

enum HeaderKeys : String {
    case wexApiKey = "wex.api.key"
    case wexUserUuid = "wex.user.uuid"
}

public class WEXSessionManager {
    
    // MARK:- Public api
    
    public init(configuration: WEXNetworkingConfigurationProtocol) {
        self.configuration = configuration
    }
    
    lazy public internal (set) var firstRegistrationSession: URLSession = {
        return makeFirstRegistrationSession()
    }()
    
    lazy public internal (set) var wexUserSession: URLSession = {
        makeWexUserSession(user: nil)
    }()
    
    lazy public internal (set) var smallImageSession: URLSession = {
        makeSmallImageSession()
    }()
    
    public func rebuildWexUserSession(user: F4SUUID) {
        wexUserSession = makeWexUserSession(user: user)
    }
    
    // MARK:- Internal storage
    
    static var shared: WEXSessionManager!
    let configuration: WEXNetworkingConfigurationProtocol
    private (set) var userUUid: F4SUUID? = nil
    
}

// MARK:- Implementation
extension WEXSessionManager {
    func makeSmallImageCache() -> URLCache {
        let memory = 5 * 1024 * 1024
        let disk = 10 * memory
        let diskpath = "smallImageCache"
        return URLCache(memoryCapacity: memory, diskCapacity: disk, diskPath: diskpath)
    }
    
    private func makeFirstRegistrationSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = firstRegistrationHeaders
        return URLSession(configuration: configuration)
    }
    
    private func makeWexUserSession(user: F4SUUID?) -> URLSession {
        self.userUUid = user
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = defaultHeaders
        return URLSession(configuration: configuration)
    }
    
    private func makeSmallImageSession() -> URLSession {
        return URLSession(configuration: makeSmallImageConfiguration())
    }
    
    func makeSmallImageConfiguration() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.allowsCellularAccess = true
        configuration.urlCache = makeSmallImageCache()
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return configuration
    }
    
    var firstRegistrationHeaders: Headers {
        return [HeaderKeys.wexApiKey.rawValue: configuration.wexApiKey]
    }
    
    var defaultHeaders: Headers {
        guard let userUUid = userUUid else { return firstRegistrationHeaders }
        var headers = Headers()
        headers[HeaderKeys.wexApiKey.rawValue] = configuration.wexApiKey
        headers[HeaderKeys.wexUserUuid.rawValue] = userUUid
        return headers
    }
}

