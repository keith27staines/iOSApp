//
//  PartnerService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 31/10/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import KeychainSwift

class PartnerService: ApiBaseService {
    class var sharedInstance: PartnerService {
        struct Static {
            static let instance: PartnerService = PartnerService()
        }
        return Static.instance
    }
    
    func getAllPartners(getCompleted: @escaping (_ succeeded: Bool, _ result: Result<[Partner]>) -> Void) {
        let url = ApiConstants.allPartnersUrl
        
        get(url) {
            _, msg in
            switch msg
            {
            case let .value(boxedJson):
                let result = DeserializationManager.sharedInstance.parsePartner(jsonOptional: boxedJson.value)
                switch result
                {
                case .error:
                    getCompleted(false, .deffinedError(Errors.GeneralCallErrors.GeneralError))
                    
                case let .deffinedError(error):
                    getCompleted(false, .deffinedError(error))
                    
                case let .value(boxed):
                    getCompleted(true, .value(Box(boxed.value)))
                }
                
            case .error:
                getCompleted(false, .deffinedError(Errors.GeneralCallErrors.GeneralError))
                
            case let .deffinedError(error):
                getCompleted(false, .deffinedError(error))
            }
        }
    }
}
