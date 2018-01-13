//
//  UserService.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 11/14/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import KeychainSwift

class UserService: ApiBaseService {
    class var sharedInstance: UserService {
        struct Static {
            static let instance: UserService = UserService()
        }
        return Static.instance
    }

    // MARK: - calls
    
    func hasAccount() -> Bool {
        return UserDefaults.standard.object(forKey: UserDefaultsKeys.userHasAccount) != nil && UserDefaults.standard.bool(forKey: UserDefaultsKeys.userHasAccount)
    }
    
    var vendorID: String { return UIDevice.current.identifierForVendor!.uuidString }
    
    func createUserOnServer(postCompleted: @escaping (_ succeeded: Bool, _ msg: Result<String>) -> Void) {
        let url = ApiConstants.userProfileUrl
        let params: Parameters = ["vendor_uuid": vendorID] as [String: Any]
        post(params, url: url) {
            _, msg in
            switch msg
            {
            case let .value(boxedJson):
                let result = DeserializationManager.sharedInstance.parseCreateProfile(jsonOptional: boxedJson.value)
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
    
    func updateUser(user: User, putCompleted: @escaping (_ succeeded: Bool, _ msg: Result<String>) -> Void) {
        let keychain = KeychainSwift()
        var currentUserUuid: String = ""

        if let userUuid = keychain.get(UserDefaultsKeys.userUuid) {
            currentUserUuid = userUuid
        }

        let url = ApiConstants.updateUserProfileUrl + currentUserUuid
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        let formatedDateOfBirth = dateFormatter.date(from: user.dateOfBirth)!.rfc3339UtcDate
        var params: Parameters = [
            "first_name": user.firstName,
            "email": user.email,
            "date_of_birth": formatedDateOfBirth,
            "requires_consent": user.requiresConsent,
            "placement_uuid": user.placementUuid,
        ] as [String: Any]
        
        if !user.lastName.isEmpty {
            params["last_name"] = user.lastName
        }

        if var partner = PartnersModel.sharedInstance.selectedPartner {
            partner = partner.updatingWithServerSideUUID()
            let partnerDictionary = ["uuid" : partner.uuid]
            params["partners"] = [partnerDictionary]
        }

        put(params, url: url) {
            _, msg in
            switch msg
            {
            case let .value(boxedJson):
                let result = DeserializationManager.sharedInstance.parseUpdateUserProfile(jsonOptional: boxedJson.value)
                switch result
                {
                case .error:
                    putCompleted(false, .deffinedError(Errors.GeneralCallErrors.GeneralError))

                case let .deffinedError(error):
                    putCompleted(false, .deffinedError(error))

                case let .value(boxed):
                    let userUuid = boxed.value
                    keychain.set(userUuid, forKey: UserDefaultsKeys.userUuid)
                    putCompleted(true, .value(Box(boxed.value)))
                }

            case .error:
                putCompleted(false, .deffinedError(Errors.GeneralCallErrors.GeneralError))

            case let .deffinedError(error):
                putCompleted(false, .deffinedError(error))
            }
        }
    }

    // MARK: - operations
    func createUser(retryCount: Int = 0, completed: @escaping (_ succeeded: Bool) -> Void) {
        guard !UserService.sharedInstance.hasAccount() else {
            // user has already been created
            return
        }
        // create new user
        DispatchQueue.global().async {
            UserService.sharedInstance.createUserOnServer(postCompleted: {
                _, result in
                switch result
                {
                case let .value(boxedValue):
                    log.debug("user created ok. Profile uuid from wex is: \(boxedValue.value)")
                    let keychain = KeychainSwift()
                    keychain.set(boxedValue.value, forKey: UserDefaultsKeys.userUuid)
                    UserDefaults.standard.set(true, forKey: UserDefaultsKeys.userHasAccount)
                    completed(true)
                    break
                case let .error(error):
                    if retryCount < 2 {
                        log.debug("Failed to create user on retry \(retryCount).\n Error was: \(error)")
                        UserService.sharedInstance.createUser(retryCount: retryCount + 1, completed: {
                            _ in
                            completed(false)
                        })
                    } else {
                        log.debug("Failed to create user after all allowed retries. Error was: \(error)")
                    }
                    break
                case let .deffinedError(error):
                    if retryCount < 2 {
                        log.debug("Failed to create user on retry \(retryCount).\n Error was: \(error)")
                        UserService.sharedInstance.createUser(retryCount: retryCount + 1, completed: {
                            _ in
                            completed(false)
                        })
                    } else {
                        log.debug("Failed to create user after all allowed retries. Error was: \(error)")
                    }
                    break
                }
            })
        }
    }

    func enablePushNotificationForUser(withDeviceToken: String, putCompleted: @escaping (_ succeeded: Bool, _ msg: Result<String>) -> Void) {

        let vendorId: String = UserService.sharedInstance.vendorID
        let url = ApiConstants.userProfileUrl + "/" + vendorId
        let params: Parameters = ["push_token": withDeviceToken] as [String: Any]

        put(params, url: url) {
            _, msg in
            switch msg
            {
            case let .value(boxedJson):
                let result = DeserializationManager.sharedInstance.parseEnablePushNotification(jsonOptional: boxedJson.value)
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

    func getUnreadMessagesCount(getCompleted: @escaping (_ succeeded: Bool, _ result: Result<UserStatus>) -> Void) {
        let url = ApiConstants.unreadMessagesCountUrl

        get(url) {
            _, msg in
            switch msg
            {
            case let .value(boxedJson):
                let result = DeserializationManager.sharedInstance.parseUnreadMessagesCount(jsonOptional: boxedJson.value)
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
