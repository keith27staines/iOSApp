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
    func createUser(userId: String = "1", postCompleted: @escaping (_ succeeded: Bool, _ msg: Result<String>) -> Void) {
        let url = ApiConstants.userProfileUrl
        let params: Parameters = ["vendor_uuid": userId] as [String: Any]
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
            "first_name": user.firstName, "email": user.email,
            "date_of_birth": formatedDateOfBirth,
            "requires_consent": user.requiresConsent, "placement_uuid": user.placementUuid,
        ] as [String: Any]
        if !user.lastName.isEmpty {
            params["last_name"] = user.lastName
        }

        if user.requiresConsent {
            params["consenter_email"] = user.consenterEmail
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

    func handleUserCreation(retryCount: Int = 0, completed: @escaping (_ succeeded: Bool) -> Void) {
        if UserDefaults.standard.object(forKey: UserDefaultsKeys.userHasAccount) == nil || !UserDefaults.standard.bool(forKey: UserDefaultsKeys.userHasAccount) {
            // create new user
            let randomUuid = UserService.sharedInstance.generateRandomUuid()
            DispatchQueue.global().async {
                UserService.sharedInstance.createUser(userId: randomUuid, postCompleted: {
                    _, result in
                    switch result
                    {
                    case let .value(boxedValue):
                        log.debug("profile uuid: \(boxedValue.value)")
                        let keychain = KeychainSwift()
                        keychain.set(boxedValue.value, forKey: UserDefaultsKeys.userUuid)
                        keychain.set(randomUuid, forKey: UserDefaultsKeys.vendorUuid)
                        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.userHasAccount)
                        completed(true)
                        break
                    case let .error(error):
                        log.debug(error)
                        if retryCount < 2 {
                            UserService.sharedInstance.handleUserCreation(retryCount: retryCount + 1, completed: {
                                _ in
                                completed(false)
                            })
                        }
                        break
                    case let .deffinedError(error):
                        log.debug(error)
                        if retryCount < 2 {
                            UserService.sharedInstance.handleUserCreation(retryCount: retryCount + 1, completed: {
                                _ in
                                completed(false)
                            })
                        }
                        break
                    }
                })
            }
        }
    }

    func enablePushNotificationForUser(withDeviceToken: String, putCompleted: @escaping (_ succeeded: Bool, _ msg: Result<String>) -> Void) {

        let keychain = KeychainSwift()
        var currentUserUuid: String = ""

        if let vendorUuid = keychain.get(UserDefaultsKeys.vendorUuid) {
            currentUserUuid = vendorUuid
        }

        let url = ApiConstants.userProfileUrl + "/" + currentUserUuid

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

    private func generateRandomUuid() -> String {
        let currentTimestamp = Date().timeIntervalSince1970
        let randomString = String.randomString(length: 20)
        let randomUuid = "\(currentTimestamp)\(randomString)"
        let encryptedRandomUuid = randomUuid.sha1()
        print(encryptedRandomUuid)
        return encryptedRandomUuid
    }
}