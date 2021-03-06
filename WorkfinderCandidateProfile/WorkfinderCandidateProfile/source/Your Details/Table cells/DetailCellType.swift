//
//  CellType.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 13/04/2021.
//

import Foundation
import WorkfinderCommon

enum DetailCellType {
    case firstname
    case lastname
    case email
    case password
    case phone
    case smsPreference
    case dob
    case postcode
    case removeAccount
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
        case .firstname:
            return { string in
                string?.isValidNameComponent ?? !self.isRequired
            }
        case .lastname:
            return { string in
                string?.isValidNameComponent ?? !self.isRequired
            }
        case .email:
            return { string in
                string?.isEmail() ?? !self.isRequired
            }
        case .password:
            return nil
        case .phone:
            return { string in
                string == "" || (string?.isPhoneNumber() ?? !self.isRequired)
            }
        case .smsPreference:
            return nil
        case .dob:
            return nil
        case .postcode:
            return { string in
                if !self.isRequired && optionalStringIsEmptyOrNil(string) { return true }
                return string?.isUKPostcode() == true
            }
        case .picklist:
            return nil
        case .removeAccount:
            return nil
        }
    }
    
    private func optionalStringIsEmptyOrNil(_ string: String?) -> Bool {
        guard let string = string, string.count > 0 else { return true }
        return false
    }
    
    var title: String? {
        switch self {
        case .firstname: return "First Name"
        case .lastname: return "Last Name"
        case .email: return "Email Address"
        case .password: return "Password"
        case .phone: return "Phone Number"
        case .smsPreference: return "Messaging Preference"
        case .dob: return "Date of Birth"
        case .postcode: return "Postcode"
        case .picklist(let type): return type.title
        case .removeAccount: return "Close your Workfinder account"
        }
    }
    
    var dataType: DataType {
        switch self {
        case .firstname: return .text(.firstname)
        case .lastname: return .text(.firstname)
        case .email: return .text(.email)
        case .password: return .password
        case .phone: return .text(.phone)
        case .smsPreference: return .boolean
        case .dob: return .date
        case .postcode: return .text(.postcode)
        case .picklist(let type): return .picklist(type)
        case .removeAccount: return .action
        }
    }
    
    var placeholderText: String? {
        switch self {
        case .firstname: return "First name"
        case .lastname: return "Last name"
        case .email: return "Email address"
        case .password: return nil
        case .phone: return "Phone"
        case .smsPreference: return "SMS preference"
        case .dob: return "Tap to enter date of birth"
        case .postcode: return "Postcode"
        case .picklist(_): return nil
        case .removeAccount: return nil
        }
    }
    
    var isRequired: Bool {
        switch self {
        case .firstname, .lastname, .email:
            return true
        default:
            return false
        }
    }
    
    var description: String? {
        switch self {
        case .firstname, .lastname: return nil
        case .email: return nil
        case .password: return nil
        case .phone: return "Add your mobile number to help employers contact you when you are offered a role"
        case .smsPreference: return "Allow Workfinder to contact me about personalised opportunities through text messages"
        case .dob: return nil
        case .postcode: return "This allows us to bring opportunities to your attention that are local to you"
        case .picklist(let type): return type.reasonForCollection
        case .removeAccount: return "You can remove your account at any time. Please note that all previous applications and profile data will be lost."
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
    case boolean
    case action
}

enum StringType {
    case firstname
    case lastname
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
