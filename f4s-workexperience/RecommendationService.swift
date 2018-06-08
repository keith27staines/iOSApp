//
//  RecommendationService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 04/01/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public class F4SRecommendationService : F4SDataTaskService {
    public static let apiName = "recommend"
    public init() {
        super.init(baseURLString: Config.BASE_URL, apiName: F4SRecommendationService.apiName)
    }

    public func fetch(completion: @escaping (F4SNetworkResult<[Recommendation]>) -> ()) {
        super.beginGetRequest(attempting: "Get recommendations", completion: completion)
    }
}




