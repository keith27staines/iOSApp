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
    public static let apiName = "recommend"
    public typealias SuccessType = [Recommendation]
    public init() {
        super.init(baseURLString: Config.BASE_URL, apiName: F4SRecommendationService.apiName, objectType: SuccessType.self)
    }

    public func fetch(completion: @escaping (F4SNetworkResult<SuccessType>) -> ()) {
        let rec = Recommendation(companyUUID: "3ba32ef4d8864b27a306dd42898d6306", sortIndex: 0)
        let res = F4SNetworkResult.success([rec])
        completion(res)
        //super.get(attempting: "Get recommendations", completion: completion)
    }
}

public struct JsonRecommedations : Decodable {
    public var data: [Recommendation]
}




