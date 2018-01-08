//
//  RecommendationService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 04/01/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import KeychainSwift

public class F4SRecommendationService : F4SDataTaskService {
    
    public typealias SuccessType = [Recommendation]
    
    public init() {
        super.init(baseURLString: Config.BASE_URL, apiName: "recommend", objectType: SuccessType.self)
    }

    public func fetch(completion: @escaping (F4SNetworkResult<SuccessType>) -> ()) {
        super.get(completion: completion)
    }
}



