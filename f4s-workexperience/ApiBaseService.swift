//
//  ApiBaseService.swift
//  f4s-workexperience
//
//  Created by Andreea Rusu on 26/04/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import Reachability
import KeychainSwift

class ApiBaseService {

    func post(_ params: Parameters?, array _: Array<AnyObject>? = nil, url: String, postCompleted: @escaping (_ succeeded: Bool, _ msg: Result<JSON>) -> Void) {

        if let reachability = Reachability() {
            if !reachability.isReachableByAnyMeans {
                postCompleted(false, .error("No Internet Connection."))
                return
            }
        }

        var header: HTTPHeaders? = ["wex.api.key": ApiConstants.apiKey]

        let keychain = KeychainSwift()
        if let userUuid = keychain.get(UserDefaultsKeys.userUuid) {
            header?["wex.user.uuid"] = userUuid
        }

        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header)
            .responseJSON { response in
                switch response.result {
                case .failure(let error):
                    log.error(error)
                    if response.response != nil {
                        switch response.response!.statusCode {
                        case 401:
                            postCompleted(false, .error("Credentials not provided or incorrect"))
                            return
                        case 403:
                            postCompleted(false, .error("API user doesn’t have access to this method"))
                            return
                        case 404:
                            postCompleted(false, .error("Incorrect URL (API method not found)"))
                            return
                        case 429:
                            postCompleted(false, .error("Number of API requests per time unit was reached"))
                            return
                        case 500:
                            postCompleted(false, .error("Bad request (parameters were incorrect or missing)"))
                            return
                        default:
                            postCompleted(false, .error("error"))
                            return
                        }
                    }

                    postCompleted(false, .error("No Internet Connection."))

                case .success(let responseObject):
                    let json = JSON(responseObject)
                    if json != JSON.null {
                        postCompleted(true, .value(Box(json)))
                        return
                    } else {
                        postCompleted(false, .error("Unprocessable Entity!"))
                        return
                    }
                }
            }
    }

    func get(_ url: String, getCompleted: @escaping (_ succeeded: Bool, _ msg: Result<JSON>) -> Void) {

        if let reachability = Reachability() {
            if !reachability.isReachableByAnyMeans {
                getCompleted(false, .error("No Internet Connection."))
                return
            }
        }

        var header: HTTPHeaders? = ["wex.api.key": ApiConstants.apiKey]

        let keychain = KeychainSwift()
        if let userUuid = keychain.get(UserDefaultsKeys.userUuid) {
            header?["wex.user.uuid"] = userUuid
        }
        Alamofire.SessionManager.default.session.configuration.timeoutIntervalForRequest = 10
        Alamofire.request(url, method: .get, headers: header)
            .responseJSON { response in
                switch response.result {
                case .failure(let error):
                    log.error(error)
                    if response.response == nil {
                        if error._code == NSURLErrorTimedOut {
                            getCompleted(false, .error("Request timed out"))
                            return
                        } else {
                            getCompleted(false, .error("No Internet Connection."))
                        }
                    } else {
                        switch response.response!.statusCode {
                        case 401:
                            getCompleted(false, .error("Credentials not provided or incorrect"))
                            return
                        case 403:
                            getCompleted(false, .error("API user doesn’t have access to this method"))
                            return
                        case 404:
                            getCompleted(false, .error("Incorrect URL (API method not found)"))
                            return
                        case 429:
                            getCompleted(false, .error("Number of API requests per time unit was reached"))
                            return
                        case 500:
                            getCompleted(false, .error("Bad request (parameters were incorrect or missing)"))
                            return
                        default:
                            getCompleted(false, .error("error"))
                            return
                        }
                    }

                case .success(let responseObject):
                    let json = JSON(responseObject)
                    if json != JSON.null {
                        getCompleted(true, .value(Box(json)))
                        return
                    } else {
                        getCompleted(false, .error("Unprocessable Entity!"))
                        return
                    }
                }
            }
    }

    func put(_ params: Parameters?, array _: Array<AnyObject>? = nil, url: String, putCompleted: @escaping (_ succeeded: Bool, _ msg: Result<JSON>) -> Void) {

        if let reachability = Reachability() {
            if !reachability.isReachableByAnyMeans {
                putCompleted(false, .error("No Internet Connection."))
                return
            }
        }

        var header: HTTPHeaders? = ["wex.api.key": ApiConstants.apiKey]

        let keychain = KeychainSwift()
        if let userUuid = keychain.get(UserDefaultsKeys.userUuid) {
            header?["wex.user.uuid"] = userUuid
        }

        Alamofire.request(url, method: .put, parameters: params, encoding: JSONEncoding.default, headers: header)
            .responseJSON { response in
                switch response.result {
                case .failure(let error):
                    log.error(error)
                    if response.response != nil {
                        switch response.response!.statusCode {
                        case 401:
                            putCompleted(false, .error("Credentials not provided or incorrect"))
                            return
                        case 403:
                            putCompleted(false, .error("API user doesn’t have access to this method"))
                            return
                        case 404:
                            putCompleted(false, .error("Incorrect URL (API method not found)"))
                            return
                        case 429:
                            putCompleted(false, .error("Number of API requests per time unit was reached"))
                            return
                        case 500:
                            putCompleted(false, .error("Bad request (parameters were incorrect or missing)"))
                            return
                        default:
                            putCompleted(false, .error("error"))
                            return
                        }
                    }

                    putCompleted(false, .error("No Internet Connection."))

                case .success(let responseObject):
                    let json = JSON(responseObject)
                    print(json)
                    if json != JSON.null {
                        putCompleted(true, .value(Box(json)))
                        return
                    } else {
                        putCompleted(false, .error("Unprocessable Entity!"))
                        return
                    }
                }
            }
    }

    func options(url: String, optionsCompleted: @escaping (_ succeeded: Bool, _ msg: Result<JSON>) -> Void) {

        if let reachability = Reachability() {
            if !reachability.isReachableByAnyMeans {
                optionsCompleted(false, .error("No Internet Connection."))
                return
            }
        }

        var header: HTTPHeaders? = ["wex.api.key": ApiConstants.apiKey]

        let keychain = KeychainSwift()
        if let userUuid = keychain.get(UserDefaultsKeys.userUuid) {
            header?["wex.user.uuid"] = userUuid
        }

        Alamofire.request(url, method: .options, encoding: JSONEncoding.default, headers: header)
            .responseJSON { response in
                switch response.result {
                case .failure(let error):
                    log.error(error)
                    if response.response != nil {
                        switch response.response!.statusCode {
                        case 401:
                            optionsCompleted(false, .error("Credentials not provided or incorrect"))
                            return
                        case 403:
                            optionsCompleted(false, .error("API user doesn’t have access to this method"))
                            return
                        case 404:
                            optionsCompleted(false, .error("Incorrect URL (API method not found)"))
                            return
                        case 429:
                            optionsCompleted(false, .error("Number of API requests per time unit was reached"))
                            return
                        case 500:
                            optionsCompleted(false, .error("Bad request (parameters were incorrect or missing)"))
                            return
                        default:
                            optionsCompleted(false, .error("error"))
                            return
                        }
                    }

                    optionsCompleted(false, .error("No Internet Connection."))

                case .success(let responseObject):
                    let json = JSON(responseObject)
                    if json != JSON.null {
                        optionsCompleted(true, .value(Box(json)))
                        return
                    } else {
                        optionsCompleted(false, .error("Unprocessable Entity!"))
                        return
                    }
                }
            }
    }

    func delete(url: String, deleteCompleted: @escaping (_ succeeded: Bool, _ msg: Result<JSON>) -> Void) {

        if let reachability = Reachability() {
            if !reachability.isReachableByAnyMeans {
                deleteCompleted(false, .error("No Internet Connection."))
                return
            }
        }

        var header: HTTPHeaders? = ["wex.api.key": ApiConstants.apiKey]

        let keychain = KeychainSwift()
        if let userUuid = keychain.get(UserDefaultsKeys.userUuid) {
            header?["wex.user.uuid"] = userUuid
        }

        Alamofire.request(url, method: .options, encoding: JSONEncoding.default, headers: header)
            .responseJSON { response in
                switch response.result {
                case .failure(let error):
                    log.error(error)
                    if response.response != nil {
                        switch response.response!.statusCode {
                        case 401:
                            deleteCompleted(false, .error("Credentials not provided or incorrect"))
                            return
                        case 403:
                            deleteCompleted(false, .error("API user doesn’t have access to this method"))
                            return
                        case 404:
                            deleteCompleted(false, .error("Incorrect URL (API method not found)"))
                            return
                        case 429:
                            deleteCompleted(false, .error("Number of API requests per time unit was reached"))
                            return
                        case 500:
                            deleteCompleted(false, .error("Bad request (parameters were incorrect or missing)"))
                            return
                        default:
                            deleteCompleted(false, .error("error"))
                            return
                        }
                    }

                    deleteCompleted(false, .error("No Internet Connection."))

                case .success(let responseObject):
                    let json = JSON(responseObject)
                    if json != JSON.null {
                        deleteCompleted(true, .value(Box(json)))
                        return
                    } else {
                        deleteCompleted(false, .error("Unprocessable Entity!"))
                        return
                    }
                }
            }
    }

    func download(_ url: String, localUrlToSave: URL, completed: @escaping (_ succeeded: Bool, _ msg: Result<String>) -> Void) {

        if let reachability = Reachability() {
            if !reachability.isReachableByAnyMeans {
                completed(false, .error("No Internet Connection."))
                return
            }
        }

        Alamofire.download(url, to: { _, _ in
            return (localUrlToSave, DownloadRequest.DownloadOptions.removePreviousFile)
        }).response {
            response in
            if let error = response.error {
                log.error(error)
                if response.response != nil {
                    switch response.response!.statusCode {
                    case 401:
                        completed(false, .error("Credentials not provided or incorrect"))
                        return
                    case 403:
                        completed(false, .error("API user doesn’t have access to this method"))
                        return
                    case 404:
                        completed(false, .error("Incorrect URL (API method not found)"))
                        return
                    case 429:
                        completed(false, .error("Number of API requests per time unit was reached"))
                        return
                    case 500:
                        completed(false, .error("Bad request (parameters were incorrect or missing)"))
                        return
                    default:
                        completed(false, .error("error"))
                        return
                    }
                }

                completed(false, .error("No Internet Connection."))
            } else {
                if let destinationUrl = response.destinationURL {
                    completed(true, .value(Box(destinationUrl.absoluteString)))
                }
                completed(true, .value(Box("")))
            }
        }
    }

    func terminateAllCalls() {
        let session = Alamofire.SessionManager.default.session
        session.getTasksWithCompletionHandler {
            dataTasks, _, _ in

            for task in dataTasks {
                task.cancel()
            }
        }
    }
}

final class Box<A> {
    let value: A

    init(_ value: A) {
        self.value = value
    }
}

enum Result<A> {
    case error(String)
    case deffinedError(CallError)
    case value(Box<A>)
}
