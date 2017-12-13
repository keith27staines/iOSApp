//
//  Versioning.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 12/12/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import KeychainSwift

class VersioningService: ApiBaseService {
    
    class var sharedInstance: VersioningService {
        struct Static {
            static let instance: VersioningService = VersioningService()
        }
        return Static.instance
    }
    
    public static var releaseVersionNumber: String? {
        let infoDictionary = Bundle.main.infoDictionary
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    public static var buildVersionNumber: String? {
        let infoDictionary = Bundle.main.infoDictionary
        return infoDictionary?["CFBundleVersion"] as? String
    }
    
    public func getIsVersionValid(completed: @escaping (_ succeeded: Bool, _ msg: Result<Bool>) -> Void) {
        let url = ApiConstants.versionUrl
        let version = VersioningService.releaseVersionNumber!
        let params: Parameters = ["version": version] as [String: Any]
        post(params, url: url) {
            _, msg in
            switch msg
            {
            case let .value(boxedJson):
                let result = DeserializationManager.sharedInstance.parseBoolean(jsonOptional: boxedJson.value)
                switch result
                {
                case .error:
                completed(false, .deffinedError(Errors.GeneralCallErrors.GeneralError))
                    
                case let .deffinedError(error):
                    completed(false, .deffinedError(error))
                    
                case let .value(boxed):
                    completed(true, .value(Box(boxed.value)))
                }
                
            case .error:
                completed(false, .deffinedError(Errors.GeneralCallErrors.GeneralError))
                
            case let .deffinedError(error):
                completed(false, .deffinedError(error))
            }
        }
    }
}


