//
//  F4SContentService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 06/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public protocol F4SContentServiceProtocol {
    var apiName: String { get }
    func getContent(completion: @escaping (F4SNetworkResult<[F4SContentDescriptor]>) -> ())
}

public class F4SContentService : F4SDataTaskService {
    public init() {
        super.init(baseURLString: NetworkConfig.workfinderApiV2, apiName: "content")
    }
}

// MARK:- F4SContentServiceProtocol conformance
extension F4SContentService : F4SContentServiceProtocol {
    public func getContent(completion: @escaping (F4SNetworkResult<[F4SContentDescriptor]>) -> ()) {
        beginGetRequest(attempting: "Get content", completion: completion)
    }
}
