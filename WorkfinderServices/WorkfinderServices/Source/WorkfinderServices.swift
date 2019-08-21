//
//  WorkfinderServices.swift
//  WorkfinderServices
//
//  Created by Keith Dev on 27/07/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderNetworking

var logger: NetworkCallLogger? { return WorkfinderNetworking.networkCallLogger }

public protocol F4SPlacementServiceProtocol : F4SGetAllPlacementsServiceProtocol {
    func ratePlacement(placementUuid: String, rating: Int, completion: @escaping ( F4SNetworkResult<Bool>) -> ()) throws
}

public protocol F4SGetAllPlacementsServiceProtocol {
    func getAllPlacementsForUser(completion: @escaping (_ result: F4SNetworkResult<[F4STimelinePlacement]>) -> ())
}
