//
//  VoucherService.swift
//  f4s-workexperience
//
//  Created by Sergiu Simon on 14/12/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import KeychainSwift

class VoucherService: ApiBaseService {
    class var sharedInstance: VoucherService {
        struct Static {
            static let instance: VoucherService = VoucherService()
        }
        return Static.instance
    }

    func validateVoucher(voucherCode: String = "", placementUuid: String = "", putCompleted: @escaping (_ succeeded: Bool, _ msg: Result<String>) -> Void) {
        let url = ApiConstants.voucherUrl + voucherCode
        let params: Parameters = ["placement_uuid": placementUuid] as [String: Any]

        put(params, url: url) {
            _, msg in
            switch msg
            {
            case let .value(boxedJson):
                let result = DeserializationManager.sharedInstance.parseVoucher(jsonOptional: boxedJson.value)
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
