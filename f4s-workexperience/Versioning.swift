//
//  Versioning.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 12/12/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

public typealias F4SVersionValidity = Bool

public protocol F4SWorkfinderVersioningServiceProtocol {
    static var releaseVersionNumber: String? { get }
    static var buildVersionNumber: String? { get }
    var apiName: String { get }

    func getIsVersionValid(completion: @escaping (F4SNetworkResult<F4SVersionValidity>) -> ())
}

public class F4SWorkfinderVersioningService: F4SDataTaskService {

    public init() {
        super.init(baseURLString: Config.BASE, apiName: "validation/ios-version")
    }
}

// MARK:- F4SWorkfinderVersioningServiceProtocol conformance
extension F4SWorkfinderVersioningService : F4SWorkfinderVersioningServiceProtocol {
    public static var releaseVersionNumber: String? {
        let infoDictionary = Bundle.main.infoDictionary
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    public static var buildVersionNumber: String? {
        let infoDictionary = Bundle.main.infoDictionary
        return infoDictionary?["CFBundleVersion"] as? String
    }
    
    public func isUpdateAvailable() -> Bool {
        let id = "com.f4s.workexperience.f4s"
        guard
            let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let _ = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(id)"),
            let data = try? Data(contentsOf: url),
            let json = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as! [String: Any],
            let results = json["results"] as? [Any],
            let result = results.first as? [String: String],
            let version = result["version"]
            else {
                return false
        }
        return version != currentVersion
    }
    
    public func getIsVersionValid(completion: @escaping (F4SNetworkResult<F4SVersionValidity>) -> ()) {
        guard let version = F4SWorkfinderVersioningService.releaseVersionNumber else {
            completion(F4SNetworkResult.success(true))
            return
        }
        let postObject = ["version" : version]
        super.beginSendRequest(verb: .post, objectToSend: postObject, attempting: "Check version is valid") { (result) in
            switch result {
                
            case .error(let error):
                let result = F4SNetworkResult<F4SVersionValidity>.error(error)
                completion(result)
            case .success(let data):
                guard let data = data else {
                    let versionIsValid = false
                    let result = F4SNetworkResult<F4SVersionValidity>.success(versionIsValid)
                    completion(result)
                    return
                }
                let versionIsValid = Bool(String(data: data, encoding: .utf8)!) ?? false
                let result = F4SNetworkResult.success(versionIsValid)
                completion(result)
            }
        }
    }
}


