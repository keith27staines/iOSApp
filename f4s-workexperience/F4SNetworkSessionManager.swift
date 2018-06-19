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
    
    public internal (set) lazy var interactiveSession: URLSession = {
        return URLSession(configuration: interactiveConfiguration)
    }()
    
    
    // MARK:- Internal properties
    internal lazy var defaultHeaders : [String:String] = {
        var header: [String : String] = ["wex.api.key": ApiConstants.apiKey]
        let keychain = KeychainSwift()
        if let userUuid = keychain.get(UserDefaultsKeys.userUuid) {
            header["wex.user.uuid"] = userUuid
        }
        return header
    }()
    
    internal lazy var interactiveConfiguration: URLSessionConfiguration = {
        return setupCommonConfiguration(URLSessionConfiguration.default)
    }()

}

extension F4SNetworkSessionManager {

    
    func setupCommonConfiguration(_ configuration: URLSessionConfiguration) -> URLSessionConfiguration {
        configuration.httpAdditionalHeaders = defaultHeaders
        configuration.allowsCellularAccess = true
        configuration.sessionSendsLaunchEvents = true
        if #available(iOS 11.0, *) {
            configuration.waitsForConnectivity = true
            configuration.multipathServiceType = .handover
        }
        return configuration
    }
}

















