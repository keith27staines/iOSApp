//
//  F4SPlacementService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 21/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public protocol F4SPlacementServiceProtocol {
    func getAllPlacementsForUser(completed: @escaping (_ result: F4SNetworkResult<[F4STimeline]>) -> ())
    func createPlacement(placement: F4SPlacement, postCompleted: @escaping (_ result: F4SNetworkResult<F4SUUID>) -> ())
}
