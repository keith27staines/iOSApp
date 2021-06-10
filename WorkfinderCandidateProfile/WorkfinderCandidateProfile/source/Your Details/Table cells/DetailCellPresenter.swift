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
    var isOn: Bool = false {
        didSet {
            onValueChanged?(self)
        }
    }
    var text: String? {
        didSet {
            onValueChanged?(self)
        }
    }
    var date: Date? { didSet { onValueChanged?(self) } }
    var selectedItems: [CodeAndName]?
    var picklist: AccountPicklist?
    var onValueChanged: ((DetailCellPresenter) -> Void)?
    
    var formattedDate: String? {
        guard let date = date else { return nil }
        return dateFormatter.string(from: date)
    }
    
    init(type: DetailCellType) {
        self.type = type
    }
    
    init(type: DetailCellType, text: String, onValueChanged: @escaping ((DetailCellPresenter) -> Void)) {
        self.type = type
        self.onValueChanged = onValueChanged
    }
    
    init(type: DetailCellType, date: Date, onValueChanged: @escaping ((DetailCellPresenter) -> Void)) {
        self.type = type
        self.onValueChanged = onValueChanged
    }
    
    init(type: DetailCellType, picklist: AccountPicklist) {
        self.type = type
        self.picklist = picklist
    }
    
    var isValid: Bool {
        guard let validator = type.textValidator else { return true }
        return validator(text)
    }
    
    lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("MM/dd/yyyy")
        return df
    }()
    
    var accessoryType: UITableViewCell.AccessoryType {
        switch self.type {
        case .firstname, .lastname: return .none
        case .email: return .none
        case .password: return .disclosureIndicator
        case .phone: return .none
        case .smsPreference: return .none
        case .dob: return .none
        case .postcode: return .none
        case .picklist(_): return .disclosureIndicator
        case .removeAccount: return .disclosureIndicator
        }
    }
    
    var disclosureText: String? {
        switch self.type {
        case .firstname, .lastname: return nil
        case .email: return nil
        case .password: return "change"
        case .phone: return nil
        case .smsPreference: return nil
        case .dob: return nil
        case .postcode: return nil
        case .picklist(_):
            guard let picklist = picklist else { return nil }
            let numberSelected = picklist.selectionCount
            return numberSelected == 0 ? "select" :  "\(numberSelected) selected"
        case .removeAccount: return nil
        }
    }
    
    var shouldSelectRow: Bool {
        switch type {
        case .firstname, .lastname:
            return false
        case .email:
            return false
        case .password:
            return true
        case .phone:
            return false
        case .smsPreference:
            return false
        case .dob:
            return false
        case .postcode:
            return false
        case .picklist(_):
            return true
        case .removeAccount:
            return true
        }
    }
}

