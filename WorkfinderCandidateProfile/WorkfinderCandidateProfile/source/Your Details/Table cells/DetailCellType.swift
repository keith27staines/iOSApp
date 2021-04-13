//
//  CellType.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 13/04/2021.
//

import Foundation

enum DetailCellType {
    case fullname
    case email
    case password
    case phone
    case dob
    case postcode
    case languages
    case gender
    case ethnicity
    
    var textValidator: ((String?) -> Bool)? {
        switch self {
        case .fullname:
            return { string in true }
        case .email:
            return { string in true }
        case .password:
            return nil
        case .phone:
            return { string in true }
        case .dob:
            return nil
        case .postcode:
            return { string in true }
        case .languages:
            return nil
        case .gender:
            return nil
        case .ethnicity:
            return nil
        }
    }
    
    var title: String? {
        switch self {
        case .fullname: return "Full Name"
        case .email: return "Email Address"
        case .password: return "Change Password"
        case .phone: return "Phone Number"
        case .dob: return "Date of Birth"
        case .postcode: return "Postcode"
        case .languages: return "Languages"
        case .gender: return "Gender Identity"
        case .ethnicity: return "Ethicity"
        }
    }
    
    var dataType: DataType {
        switch self {
        case .fullname: return .text(.fullname)
        case .email: return .text(.email)
        case .password: return .none
        case .phone: return .text(.phone)
        case .dob: return .date
        case .postcode: return .text(.postcode)
        case .languages: return .picklist(.language)
        case .gender: return .picklist(.gender)
        case .ethnicity: return .picklist(.ethnicity)
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
        case .languages: return nil
        case .gender: return nil
        case .ethnicity: return nil
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
        case .languages: return "For employers who prefer candidates with certain language skills"
        case .gender: return "We collect this information in line with our D&I policy"
        case .ethnicity: return "We collect this information in line with our D&I policy"
        }
    }
    
    var isEditable: Bool {
        switch self {
        case .password, .languages, .gender, .ethnicity:
            return false
        default:
            return true
        }
    }
    
    var isSelectable: Bool {
        switch self {
        case .languages, .gender, .ethnicity:
            return false
        default:
            return false
        }
    }
    
    var minimumSelections: Int? {
        switch self {
        case .languages, .gender, .ethnicity:
            return 0
        default:
            return nil
        }
    }
    var maximumSelections: Int? {
        switch self {
        case .languages: return 10
        case .gender, .ethnicity: return 0
        default: return nil
        }
    }
}

enum DataType {
    case text(StringType)
    case date
    case none
    case picklist(PicklistType)
}

enum StringType {
    case fullname
    case email
    case phone
    case postcode
}
