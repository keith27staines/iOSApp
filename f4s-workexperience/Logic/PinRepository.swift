//
//  PinRepository.swift
//  FileParser
//
//  Created by Keith Dev on 07/03/2020.
//  Copyright © 2020 Founders4Schools. All rights reserved.
//

import Foundation


public class PinRepository {
    public private (set) var allPins: [PinJson]
    public init(allPins: [PinJson]) {
        self.allPins = [PinJson](allPins)
    }
    
    public func pins(interestedInAnyOf interests: Set<String>) -> [PinJson] {
        return allPins.filter { (pin) -> Bool in
            let tagSet = Set<String>(pin.tags)
            return !tagSet.isDisjoint(with: interests)
        }
    }
}
