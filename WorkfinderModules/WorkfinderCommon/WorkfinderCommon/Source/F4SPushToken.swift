//
//  F4SPushToken.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 09/08/2019.
//  Copyright © 2019 Workfinder Ltd. All rights reserved.
//

import Foundation

/// Encapsulates a push notification token
public struct F4SPushToken: Codable {
    /// The token
    public var pushToken: String
    /// Intialises a new instance
    ///
    /// - Parameter pushToken: the push notification token generated by ios 
    public init(pushToken: String) {
        self.pushToken = pushToken
    }
}

extension F4SPushToken {
    private enum CodingKeys : String, CodingKey {
        case pushToken = "push_token"
    }
}
