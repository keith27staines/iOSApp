//
//  PinRepository.swift
//  FileParser
//
//  Created by Keith Dev on 07/03/2020.
//  Copyright © 2020 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

public class PinRepository {
    public private (set) var allPins: [PinJson]
    public init(allPins: [PinJson]) {
        self.allPins = [PinJson](allPins)
    }
    
    public func pins(interestedInAnyOf interests: Set<F4SUUID>) -> [PinJson] {
        return allPins.filter { (pin) -> Bool in
            let tagSet = Set<String>(pin.tags)
            return !tagSet.isDisjoint(with: interests)
        }
    }
    
    public func pins(interestedInAnyOf interests: F4SInterestSet) -> [PinJson] {
        let uuidSet = interests.map { (interest) -> F4SUUID in
            interest.uuid
        }
        return pins(interestedInAnyOf: Set<F4SUUID>(uuidSet))
    }
}
