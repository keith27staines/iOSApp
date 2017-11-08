//
//  ReachabilityExtension.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 08/11/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import Foundation
import Reachability

extension Reachability {
    public var isReachableByAnyMeans: Bool {
        return connection != .none
    }
}
