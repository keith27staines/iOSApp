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

class RecommendationService: ApiBaseService {
    class var sharedInstance: RecommendationService {
        struct Static {
            static let instance: RecommendationService = RecommendationService()
        }
        return Static.instance
    }
    
    func getAllRecommendations(getCompleted: @escaping (_ succeeded: Bool, _ result: Result<[Recommendation]>) -> Void) {
        let url = ApiConstants.recommendationURL
        
        get(url) {
            _, msg in
            switch msg
            {
            case let .value(boxedJson):
                print(boxedJson.value)
                let d = boxedJson.value.rawString()
            
//                let result = DeserializationManager.sharedInstance.parsePartner(jsonOptional: boxedJson.value)
//                switch result
//                {
//                case .error:
//                    getCompleted(false, .deffinedError(Errors.GeneralCallErrors.GeneralError))
//                    
//                case let .deffinedError(error):
//                    getCompleted(false, .deffinedError(error))
//                    
//                case let .value(boxed):
//                    getCompleted(true, .value(Box(boxed.value)))
//                }
                
            case .error:
                getCompleted(false, .deffinedError(Errors.GeneralCallErrors.GeneralError))
                
            case let .deffinedError(error):
                getCompleted(false, .deffinedError(error))
            }
        }
    }
}

