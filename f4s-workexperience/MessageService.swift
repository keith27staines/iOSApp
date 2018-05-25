//
//  MessageService.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 1/4/17.
//  Copyright © 2017 freshbyte. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import KeychainSwift

class MessageService: ApiBaseService {
    class var sharedInstance: MessageService {
        struct Static {
            static let instance: MessageService = MessageService()
        }
        return Static.instance
    }

    func sendMessageForThread(responseUuid: String, threadUuid: String, putCompleted: @escaping (_ succeeded: Bool, _ msg: Result<[F4SMessage]>) -> Void) {
        let url = String(format: "%@%@", ApiConstants.sendMessageForThreadUrl, threadUuid)
        let params: Parameters = ["response_uuid": responseUuid] as [String: Any]

        put(params, url: url) {
            _, msg in
            switch msg
            {
            case let .value(boxedJson):
                let result = DeserializationManager.sharedInstance.parseMessagesInThread(jsonOptional: boxedJson.value)
                switch result
                {
                case .error:
                    putCompleted(false, .deffinedError(Errors.GeneralCallErrors.GeneralError))

                case let .deffinedError(error):
                    putCompleted(false, .deffinedError(error))

                case let .value(boxed):
                    putCompleted(true, .value(Box(boxed.value)))
                }

            case .error:
                putCompleted(false, .deffinedError(Errors.GeneralCallErrors.GeneralError))

            case let .deffinedError(error):
                putCompleted(false, .deffinedError(error))
            }
        }
    }
}
