//
//  WorkfinderSessionManager.swift
//  WorkfinderNetworking
//
//  Created by Keith Dev on 10/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
typealias Headers = [String:String]

enum HeaderKeys : String {
    case wexApiKey = "wex.api.key"
    case wexUserUuid = "wex.user.uuid"
}

public class WEXSessionManager {
    static var shared: WEXSessionManager!
    let configuration: WexNetworkingConfigurationProtocol
    private (set) var userUUid: F4SUUID? = nil
    
    lazy public internal (set) var firstRegistrationSession: URLSession = {
        return buildFirstRegistrationSession()
    }()
    
    lazy public internal (set) var wexUserSession: URLSession = {
        buildWexUserSession(user: nil)
    }()
    
    private func buildFirstRegistrationSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = firstRegistrationHeaders
        return URLSession(configuration: configuration)
    }
    
    @discardableResult
    func buildWexUserSession(user: F4SUUID?) -> URLSession {
        self.userUUid = user
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = defaultHeaders
        wexUserSession = URLSession(configuration: configuration)
        return wexUserSession
    }
    
    public init(configuration: WexNetworkingConfigurationProtocol) {
        self.configuration = configuration
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

