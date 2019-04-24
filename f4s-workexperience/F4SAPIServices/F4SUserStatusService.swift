//
//  F4SBadgeNumberService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 16/05/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

public struct F4SUserStatus : Codable {
    var unreadMessageCount: Int
    var unratedPlacements: [F4SUUID]
}

private extension F4SUserStatus {
    private enum CodingKeys : String, CodingKey {
        case unreadMessageCount = "unread_count"
        case unratedPlacements = "unrated"
    }
}

public protocol F4SUserStatusServiceProtocol {
    var userStatus: F4SUserStatus? { get }
    func beginStatusUpdate()
    func getUserStatus(completion: @escaping (F4SNetworkResult<F4SUserStatus>) -> ())
}

public extension Notification.Name {
    static let f4sUserStatusUpdated = Notification.Name(
        rawValue: "f4sUserStatusUpdated")
}

public class F4SUserStatusService : F4SDataTaskService {
    
    public static let shared: F4SUserStatusService = F4SUserStatusService()
    
    public var userStatus: F4SUserStatus?
    
    public init() {
        let apiName = "user/status"
        super.init(baseURLString: Config.BASE_URL, apiName: apiName)
    }
    
    public func beginStatusUpdate() {
        getUserStatus { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .error(_):
                    break
                case .success(let status):
                    self?.userStatus = status
                    let badgeNumber = status.unreadMessageCount
                    UIApplication.shared.applicationIconBadgeNumber = max(badgeNumber,0)
                    print("BADGE NUMBER = \(badgeNumber)")
                    NotificationCenter.default.post(name: .f4sUserStatusUpdated, object: status)
                }
            }
        }
    }
}

// MARK:- F4SDocumentServiceProtocol conformance
extension F4SUserStatusService : F4SUserStatusServiceProtocol {
    public func getUserStatus(completion: @escaping (F4SNetworkResult<F4SUserStatus>) -> ()) {
        beginGetRequest(attempting: "Get status for current user", completion: completion)
    }
}
