//
//  Picklist.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 13/04/2021.
//

import Foundation
import WorkfinderCommon

class AccountPicklist {
    var type: AccountPicklistType
    var items: [IdentifiedAndNamed] = []
    var selectedItems: [IdentifiedAndNamed] = []
    
    init(type: AccountPicklistType) {
        self.type = type
    }
}

enum AccountPicklistType: Int, CaseIterable {
    case language
    case gender
    case ethnicity
    
    var title: String {
        switch self {
        case .language: return "Languages"
        case .ethnicity: return "Ethnicity"
        case .gender: return "Gender identity"
        }
    }
    
    var maxSelections: Int {
        switch self {
        case .ethnicity: return 1
        case .gender: return 1
        case .language: return 10
        }
    }
    
    var reasonForCollection: String {
        switch self {
        case .language: return "For employers who prefer candidates with certain language skills"
        case .gender: return "We collect this information in line with our D&I policy"
        case .ethnicity: return "We collect this information in line with our D&I policy"
        }
    }
}
