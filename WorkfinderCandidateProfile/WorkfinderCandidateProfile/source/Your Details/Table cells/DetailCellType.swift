//
//  CellType.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 13/04/2021.
//

import Foundation
import WorkfinderCommon

enum DetailCellType {
    case fullname
    case email
    case password
    case phone
    case dob
    case postcode
    case picklist(AccountPicklistType)
    
    var textValidityState: ((String?) -> ValidityState)? {
        return { string in
            guard let string = string else { return ValidityState.isNil }
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            if !isRequired && trimmed.count == 0 { return .empty }
            return (textValidator?(trimmed) ?? true) ? .good : .bad
        }
    }
    
    var textValidator: ((String?) -> Bool)? {
        switch self {
        case .fullname:
            return { string in
                string?.isValidFullname() ?? !self.isRequired
            }
        case .email:
            return { string in
                string?.isEmail() ?? !self.isRequired
            }
        case .password:
            return nil
        case .phone:
            return { string in
                string?.isPhoneNumber() ?? !self.isRequired
            }
        case .dob:
            return nil
        case .postcode:
            return { string in
                string?.isUKPostcode() ?? !self.isRequired
            }
        case .picklist:
            return nil
        }
    }
    
    var title: String? {
        switch self {
        case .fullname: return "Full Name"
        case .email: return "Email Address"
        case .password: return "Password"
        case .phone: return "Phone Number"
        case .dob: return "Date of Birth"
        case .postcode: return "Postcode"
        case .picklist(let type): return type.title
        }
    }
    
    var dataType: DataType {
        switch self {
        case .fullname: return .text(.fullname)
        case .email: return .text(.email)
        case .password: return .password
        case .phone: return .text(.phone)
        case .dob: return .date
        case .postcode: return .text(.postcode)
        case .picklist(let type): return .picklist(type)
        }
    }
    
    var placeholderText: String? {
        switch self {
        case .fullname: return "Full name"
        case .email: return "Email address"
        case .password: return nil
        case .phone: return "Phone"
        case .dob: return "Date of birth"
        case .postcode: return "Postcode"
        case .picklist(_): return nil
        }
    }
    
    var isRequired: Bool {
        switch self {
        case .fullname, .email, .phone, .dob:
            return true
        default:
            return false
        }
    }
    
    var description: String? {
        switch self {
        case .fullname: return nil
        case .email: return nil
        case .password: return nil
        case .phone: return nil
        case .dob: return "Required for us to process your application for certain roles"
        case .postcode: return "For employers who prefer candidates in certain localities"
        case .picklist(let type): return type.reasonForCollection
        }
    }
    
    var isEditable: Bool {
        switch self {
        case .password, .picklist(_):
            return false
        default:
            return true
        }
    }
    
    var isSelectable: Bool {
        switch self {
        case .picklist(_):
            return false
        default:
            return false
        }
    }
    
    var minimumSelections: Int? {
        switch self {
        case .picklist(_):
            return 0
        default:
            return nil
        }
    }
    var maximumSelections: Int? {
        switch self {
        case .picklist(let type): return type.maxSelections
        default: return nil
        }
    }
}

enum DataType {
    case text(StringType)
    case date
    case picklist(AccountPicklistType)
    case password
}

enum StringType {
    case fullname
    case email
    case phone
    case postcode
}

enum ValidityState {
    case good
    case bad
    case empty
    case isNil
}
