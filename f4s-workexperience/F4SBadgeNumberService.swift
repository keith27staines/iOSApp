//
//  F4SBadgeNumberService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 16/05/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public struct F4SUserStatusJson : Codable {
    var unread_count: Int
    var unrated: Int
}

private extension F4SUserStatusJson {
    
}

public protocol F4SBadgeNumberServiceProtocol {
    var apiName: String { get }
    func getUserStatus(completion: @escaping (F4SNetworkResult<F4SUserStatusJson>) -> ())
}

public class F4SBadgeNumberService : F4SDataTaskService {
    public typealias SuccessType = F4SUserStatusJson
    
    public init() {
        let apiName = "user/status"
        super.init(baseURLString: Config.BASE_URL, apiName: apiName, objectType: SuccessType.self)
    }
}

// MARK:- F4SDocumentServiceProtocol conformance
extension F4SBadgeNumberService : F4SBadgeNumberServiceProtocol {
    public func getUserStatus(completion: @escaping (F4SNetworkResult<F4SUserStatusJson>) -> ()) {
        super.get(attempting: "Get status for current user", completion: completion)
    }
}
