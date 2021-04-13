//
//  CellPresenter.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 12/04/2021.
//

import UIKit
import WorkfinderCommon

class DetailCellPresenter {
    let type: DetailCellType
    var text: String?
    var date: Date?
    var selectedItems: [CodeAndName]?
    var picklist: Picklist?
    
    init(type: DetailCellType) {
        self.type = type
    }
    
    init(type: DetailCellType, text: String) {
        self.type = type
    }
    
    init(type: DetailCellType, date: Date) {
        self.type = type
    }
    
    init(type: DetailCellType, picklistItems: [CodeAndName]) {
        self.type = type
    }
    
    var isValid: Bool {
        guard let validator = type.textValidator else { return true }
        return validator(text)
    }
    
    var accessoryType: UITableViewCell.AccessoryType {
        switch self.type {
        case .fullname: return .none
        case .email: return .none
        case .password: return .disclosureIndicator
        case .phone: return .none
        case .dob: return .none
        case .postcode: return .none
        case .languages: return .disclosureIndicator
        case .gender: return .disclosureIndicator
        case .ethnicity: return .disclosureIndicator
        }
    }
    
    var disclosureText: String? {
        switch self.type {
        case .fullname: return nil
        case .email: return nil
        case .password: return nil
        case .phone: return nil
        case .dob: return nil
        case .postcode: return nil
        case .languages: return "select"
        case .gender: return "select"
        case .ethnicity: return "select"
        }
    }
}

