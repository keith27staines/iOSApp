//
//  TemplateService.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 11/28/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import SwiftyJSON

class TemplateService: ApiBaseService {
    class var sharedInstance: TemplateService {
        struct Static {
            static let instance: TemplateService = TemplateService()
        }
        return Static.instance
    }

    func getTemplate(getCompleted: @escaping (_ succeeded: Bool, _ msg: Result<[TemplateEntity]>) -> Void) {
        let url = ApiConstants.templateUrl

        get(url) {
            _, msg in
            switch msg
            {
            case let .value(boxedJson):
                let result = DeserializationManager.sharedInstance.parseTemplate(jsonOptional: boxedJson.value)
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
