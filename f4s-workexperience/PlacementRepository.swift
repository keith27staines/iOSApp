//
//  PlacementRepository.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 07/04/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

class F4SPlacementRespository : F4SPlacementRepositoryProtocol {
    func save(placement: F4SPlacement) {
        PlacementDBOperations.sharedInstance.savePlacement(placement: placement)
    }
}
