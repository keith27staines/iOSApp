//
//  RecommendationService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 04/01/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public protocol F4SRecommendationServiceProtocol : class {
    func fetch(completion: @escaping (F4SNetworkResult<[Recommendation]>) -> ())
}

public class F4SRecommendationService : F4SDataTaskService, F4SRecommendationServiceProtocol {
    public static let apiName = "recommend"
    public init() {
        super.init(baseURLString: NetworkConfig.workfinderApiV2, apiName: F4SRecommendationService.apiName)
    }

    public func fetch(completion: @escaping (F4SNetworkResult<[Recommendation]>) -> ()) {
        beginGetRequest(attempting: "Get recommendations", completion: completion)
    }
}




