//
//  ContentService.swift
//  f4s-workexperience
//
//  Created by iOS FRB on 12/9/16.
//
//

import Foundation
import SwiftyJSON

class ContentService: ApiBaseService {
    class var sharedInstance: ContentService {
        struct Static {
            static let instance: ContentService = ContentService()
        }
        return Static.instance
    }

    func getContent(getCompleted: @escaping (_ succeeded: Bool, _ msg: Result<[ContentEntity]>) -> Void) {
        let url = ApiConstants.contentUrl

        get(url) {
            _, msg in
            switch msg
            {
            case let .value(boxedJson):
                let result = DeserializationManager.sharedInstance.parseContent(jsonOptional: boxedJson.value)
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
