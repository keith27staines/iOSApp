//
//  F4SInterestsRepositoryProtocol.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 07/04/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

public protocol F4SInterestsRepositoryProtocol {
    func loadAllInterests() -> [F4SInterest]
    func loadUserInterests() -> [F4SInterest]
}
