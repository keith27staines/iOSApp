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

    func createPlacement(placement: Placement, postCompleted: @escaping (_ succeeded: Bool, _ msg: Result<String>) -> Void) {
        let url = ApiConstants.createPlacementUrl
        var params: Parameters = ["company_uuid": placement.companyUuid as Any, "interests": PlacementService.sharedInstance.getInterestList(interests: placement.interestsList)] as [String: Any]

        let keychain = KeychainSwift()
        if let userUuid = keychain.get(UserDefaultsKeys.userUuid) {
            params["user_uuid"] = userUuid
        }
        params["vendor_uuid"] = F4SUserService.vendorID

        post(params, url: url) {
            _, msg in
            switch msg
            {
            case let .value(boxedJson):
                let result = DeserializationManager.sharedInstance.parseCreatePlacement(jsonOptional: boxedJson.value)
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

    func updatePlacement(placement: Placement, template: F4STemplate, postCompleted: @escaping (_ succeeded: Bool, _ msg: Result<String>) -> Void) {
        let url = ApiConstants.updatePlacementUrl + "/\(placement.placementUuid)"
        var params: Parameters = ["company_uuid": placement.companyUuid as Any, "interests": PlacementService.sharedInstance.getInterestList(interests: placement.interestsList), "coverletter_uuid": template.uuid as Any, "uuid": placement.placementUuid as Any] as [String: Any]

        let keychain = KeychainSwift()
        if let userUuid = keychain.get(UserDefaultsKeys.userUuid) {
            params["user_uuid"] = userUuid
        }

        var coverLetterObjects: [Any] = []
        for bank in template.blanks {
            let choices = self.getChoiceList(choices: bank.choices)
            let dict: NSMutableDictionary = NSMutableDictionary()
            if bank.name == ChooseAttributes.EndDate.rawValue || bank.name == ChooseAttributes.StartDate.rawValue || bank.name == ChooseAttributes.JobRole.rawValue {
                dict["result"] = choices.first
            } else {
                dict["result"] = choices
            }

            dict["name"] = bank.name
            coverLetterObjects.append(dict)
        }
        params["coverletter_choices"] = coverLetterObjects

        put(params, url: url) {
            _, msg in
            switch msg
            {
            case let .value(boxedJson):
                let result = DeserializationManager.sharedInstance.parseUpdatePlacement(jsonOptional: boxedJson.value)
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

    func ratePlacement(uuid: String, value: Int, postCompleted: @escaping (_ succeeded: Bool, _ msg: Result<String>) -> Void) {
        let url = ApiConstants.ratingUrl

        let params: Parameters = ["value": value, "placement_uuid": uuid] as [String: Any]

        post(params, url: url) {
            _, msg in
            switch msg
            {
            case let .value(boxedJson):
                let result = DeserializationManager.sharedInstance.parseRatePlacement(jsonOptional: boxedJson.value)
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

    private func getInterestList(interests: [Interest]) -> [String] {
        var interestList: [String] = []
        for interest in interests {
            interestList.append(interest.uuid)
        }
        return interestList
    }

    private func getChoiceList(choices: [F4SChoice]) -> [String] {
        var choicesList: [String] = []
        for choice in choices {
            choicesList.append(choice.uuid)
        }
        return choicesList
    }
}
