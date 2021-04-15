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
    var picklist: AccountPicklist?
    
    init(type: DetailCellType) {
        self.type = type
    }
    
    init(type: DetailCellType, text: String) {
        self.type = type
    }
    
    init(type: DetailCellType, date: Date) {
        self.type = type
    }
    
    init(type: DetailCellType, picklist: AccountPicklist) {
        self.type = type
        self.picklist = picklist
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
        case .picklist(_): return .disclosureIndicator
        }
    }
    
    var disclosureText: String? {
        switch self.type {
        case .fullname: return nil
        case .email: return nil
        case .password: return "change"
        case .phone: return nil
        case .dob: return nil
        case .postcode: return nil
        case .picklist(_):
            guard let picklist = picklist else { return nil }
            let numberSelected = picklist.selectedItems.count
            return numberSelected == 0 ? "select" :  "\(numberSelected) selected"
        }
    }
}

