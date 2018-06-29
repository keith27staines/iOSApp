//
//  PlacementService.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 11/25/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import KeychainSwift

class PlacementService: ApiBaseService {
    class var sharedInstance: PlacementService {
        struct Static {
            static let instance: PlacementService = PlacementService()
        }
        return Static.instance
    }

    func getAllPlacementsForUser(getCompleted: @escaping (_ succeeded: Bool, _ result: Result<[TimelinePlacement]>) -> Void) {
        let url = ApiConstants.allPlacementsUrl

        get(url) {
            _, msg in
            switch msg
            {
            case let .value(boxedJson):
                let result = DeserializationManager.sharedInstance.parseTimelinePlacement(jsonOptional: boxedJson.value)
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
