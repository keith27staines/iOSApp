//
//  F4SBadgeNumberService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 16/05/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public struct F4SUserStatus : Codable {
    var unreadMessageCount: Int
    var unrated: Int
}

private extension F4SUserStatus {
    
}

public protocol F4SBadgeNumberServiceProtocol {
    var apiName: String { get }
    func getUserStatus(completion: @escaping (F4SNetworkResult<F4SUserStatus>) -> ())
}

public class F4SBadgeNumberService : F4SDataTaskService {
    
    public static let shared: F4SBadgeNumberService = F4SBadgeNumberService()
    
    public typealias SuccessType = F4SUserStatus
    
    public var userStatus: F4SUserStatus? {
        didSet {
            if let badgeNumber = userStatus?.unreadMessageCount {
                UIApplication.shared.applicationIconBadgeNumber = badgeNumber
            }
        }
    }
    
    public init() {
        let apiName = "user/status"
        super.init(baseURLString: Config.BASE_URL, apiName: apiName, objectType: SuccessType.self)
    }
    
    public func updateBadgeNumber() {
        updateBadgeNumber(maxRetries: 3)
    }
    
    private func updateBadgeNumber(maxRetries: Int) {
        getUserStatus { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .error(let error):
                    if error.retry && maxRetries > 0 {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: {
                            self?.updateBadgeNumber(maxRetries: maxRetries - 1)
                        })
                    }
                case .success(let status):
                    self?.userStatus = status
                }
            }
        }
    }
}

// MARK:- F4SDocumentServiceProtocol conformance
extension F4SBadgeNumberService : F4SBadgeNumberServiceProtocol {
    public func getUserStatus(completion: @escaping (F4SNetworkResult<F4SUserStatus>) -> ()) {
        super.get(attempting: "Get status for current user", completion: completion)
    }
}
