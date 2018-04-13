//
//  F4SFeatureSwitchService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 08/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation


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
    public typealias SuccessType = [F4SFeature]
    
    public init() {
        let apiName = "feature-flag"
        super.init(baseURLString: Config.BASE_URL, apiName: apiName, objectType: SuccessType.self)
    }
}

// MARK:- F4SFeatureSwitchServiceProtocol conformance
extension F4SFeatureSwitchService : F4SFeatureSwitchServiceProtocol {
    public func getFeatureSwitches(completion: @escaping (F4SNetworkResult<[F4SFeature]>) -> ()) {
        super.get(attempting: "Get iOS feature switches", completion: completion)
    }
}
