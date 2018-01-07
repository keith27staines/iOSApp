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

public class F4SDataTaskService : F4SApiService {
    
    private var task: URLSessionDataTask?
    public let session: URLSession
    public let baseUrl: URL
    public let apiName: String
    
    public var url : URL {
        return URL(string: apiName, relativeTo: baseUrl)!
    }
    
    public init(baseURLString: String, apiName: String, objectType: Decodable.Type) {
        self.apiName = apiName
        self.baseUrl = URL(string: baseURLString)!
        session = URLSession(configuration: F4SRecommendationService.defaultConfiguration)
    }
    
    internal func get<A>(completion: @escaping (F4SNetworkResult<A>) -> ()) {
        task?.cancel()
        task = dataTask(attempting: "Get recommendations", completion: { (result) in
            completion(result)
        })
        task?.resume()
    }
}

