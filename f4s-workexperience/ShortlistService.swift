//
//  ShortlistService.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 2/8/17.
//  Copyright © 2017 freshbyte. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import KeychainSwift

class ShortlistService: ApiBaseService {
    class var sharedInstance: ShortlistService {
        struct Static {
            static let instance: ShortlistService = ShortlistService()
        }
        return Static.instance
    }

    func shortlistCompany(companyUuid: String, postCompleted: @escaping (_ succeeded: Bool, _ msg: Result<Shortlist>) -> Void) {
        let url = ApiConstants.shortlistCompanyUrl
        let params: Parameters = ["company_uuid": companyUuid] as [String: Any]
        post(params, url: url) {
            _, msg in
            switch msg
            {
            case let .value(boxedJson):
                let result = DeserializationManager.sharedInstance.parseShortlistCompany(jsonOptional: boxedJson.value)
                switch result
                {
                case .error:
                    postCompleted(false, .deffinedError(Errors.GeneralCallErrors.GeneralError))

                case let .deffinedError(error):
                    postCompleted(false, .deffinedError(error))

                case let .value(boxed):
                    postCompleted(true, .value(Box(boxed.value)))
                }

            case .error:
                postCompleted(false, .deffinedError(Errors.GeneralCallErrors.GeneralError))

            case let .deffinedError(error):
                postCompleted(false, .deffinedError(error))
            }
        }
    }

    func unshortlistCompany(favoriteUuid: String, deleteCompleted: @escaping (_ succeeded: Bool, _ msg: Result<Bool>) -> Void) {
        let url = ApiConstants.unshortlistCompanyUrl + "/" + favoriteUuid

        delete(url: url) {
            _, msg in
            switch msg
            {
            case let .value(boxedJson):
                let result = DeserializationManager.sharedInstance.parseUnshortlistCompany(jsonOptional: boxedJson.value)
                switch result
                {
                case .error:
                    deleteCompleted(false, .deffinedError(Errors.GeneralCallErrors.GeneralError))

                case let .deffinedError(error):
                    deleteCompleted(false, .deffinedError(error))

                case let .value(boxed):
                    deleteCompleted(true, .value(Box(boxed.value)))
                }

            case .error:
                deleteCompleted(false, .deffinedError(Errors.GeneralCallErrors.GeneralError))

            case let .deffinedError(error):
                deleteCompleted(false, .deffinedError(error))
            }
        }
    }
}
