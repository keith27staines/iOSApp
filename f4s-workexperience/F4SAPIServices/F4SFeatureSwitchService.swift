//
//  F4SFeatureSwitchService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 08/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public protocol F4SFeatureSwitchServiceProtocol {
    var apiName: String { get }
    func getFeatureSwitches(completion: @escaping (F4SNetworkResult<[F4SFeature]>) -> ())
}

public class F4SFeatureSwitchServiceFake : F4SFeatureSwitchServiceProtocol {
    public var apiName: String
    
    public func getFeatureSwitches(completion: @escaping (F4SNetworkResult<[F4SFeature]>) -> ()) {
        let features: [F4SFeature] = Array<F4SFeature>(F4SFeatureSwitchKey.makeAllFeatures().values.dropLast())
        completion(F4SNetworkResult<[F4SFeature]>.success(features))
    }
    
    public init() {
        apiName = ""
    }
    
}

public class F4SFeatureSwitchService : F4SDataTaskService {
    
    public init() {
        let apiName = "feature-flag"
        super.init(baseURLString: NetworkConfig.workfinderApiV1, apiName: apiName)
    }
}

// MARK:- F4SFeatureSwitchServiceProtocol conformance
extension F4SFeatureSwitchService : F4SFeatureSwitchServiceProtocol {
    public func getFeatureSwitches(completion: @escaping (F4SNetworkResult<[F4SFeature]>) -> ()) {
        beginGetRequest(attempting: "Get iOS feature switches", completion: completion)
    }
}
