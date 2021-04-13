//
//  Picklist.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 13/04/2021.
//

import Foundation
import WorkfinderCommon

class Picklist {
    var name: String
    var items: [CodeAndName] = []
    var selectedItems: [CodeAndName] = []
    var maxSelections: Int
    
    init(name: String, items: [CodeAndName], selectedItems: [CodeAndName], maxSelections: Int = 1) {
        self.name = name
        self.items = items
        self.selectedItems = []
        self.maxSelections = maxSelections
    }
}

enum PicklistType {
    case language
    case gender
    case ethnicity
}
