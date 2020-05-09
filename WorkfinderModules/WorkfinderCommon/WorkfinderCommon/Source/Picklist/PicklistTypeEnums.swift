
import Foundation

public enum ProviderType {
    case network
    case clientTextField
    case clientTextblock
    case clientAvailabilityPeriod
}

public enum PicklistType: Int, CaseIterable, Codable {
    case roles
    case skills
    case attributes
    case universities
    case year
    case availabilityPeriod
    case motivation
    case reason
    case experience
    
    public var providerType: ProviderType {
        switch self {
        case .roles, .skills, .attributes, .universities:
            return .network
        case .year:
            return .clientTextField
        case .motivation,.reason, .experience:
            return .clientTextField
        case .availabilityPeriod:
            return .clientAvailabilityPeriod
        }
    }
    
    public var endpoint: String {
        switch self {
        case .roles: return "job-roles/"
        case .skills: return "employment-skills/"
        case .attributes: return "personal-attributes/"
        case .universities: return "institutions/"
        default: return ""
        }
    }
    
    public var title: String {
        switch self {
        case .roles:
            return NSLocalizedString("role", comment: "")
        case .skills:
            return NSLocalizedString("skills", comment: "")
        case .attributes:
            return NSLocalizedString("attributes", comment: "")
        case .universities:
            return NSLocalizedString("educational institution", comment: "")
        case .year:
            return NSLocalizedString("year", comment: "")
        case .motivation:
            return NSLocalizedString("motivation", comment: "")
        case .reason:
            return NSLocalizedString("reason", comment: "")
        case .experience:
            return NSLocalizedString("experience", comment: "")
        case .availabilityPeriod:
            return NSLocalizedString("availability", comment: "")
        }
    }
    
    public var userInstruction: String {
        switch self {
        case .roles:
            return NSLocalizedString("Select the kind of role you are looking for", comment: "")
        case .skills:
            return NSLocalizedString("Choose up to three employment skills you are hoping to acquire through this Work Experience placement", comment: "")
        case .attributes:
            return NSLocalizedString("Select up to three personal attributes that describe you", comment: "")
        case .universities:
            return NSLocalizedString("Select the university you are currently attending", comment: "")
        case .year:
            return NSLocalizedString("Select your year of study", comment: "")
        case .availabilityPeriod:
            return NSLocalizedString("Select your availability", comment: "")
        case .motivation:
            return NSLocalizedString("Your motivation", comment: "")
        case .reason:
            return NSLocalizedString("Your reason for applying", comment: "")
        case .experience:
            return NSLocalizedString("Your experience", comment: "")
        }
    }
    
    public var otherFieldGuidanceText: String {
        let things: String
        switch self {
        case .roles: things = "roles"
        case .skills: things = "skills"
        case .attributes: things = "attributes"
        case .universities: things = "universities"
        case .year: things = "study years"
        case .availabilityPeriod: things = ""
        case .motivation: things = ""
        case .reason: things = ""
        case .experience: things = ""
        }
        return "You selected 'Other' from our list of \(things). Please give more details below."
    }
    
    public var textBlockEditorTitle: String {
        switch self {
        case .roles: return ""
        case .skills: return ""
        case .attributes: return ""
        case .universities: return ""
        case .year: return ""
        case .availabilityPeriod: return ""
        case .motivation: return "Motivation"
        case .reason: return "Motivation"
        case .experience: return "Experience"
        }
    }
    
    public var otherEditorTitle: String {
        switch self {
        case .roles: return ""
        case .skills: return ""
        case .attributes: return ""
        case .universities: return ""
        case .year: return "Other year"
        case .availabilityPeriod: return ""
        case .motivation: return "Motivation"
        case .reason: return "Motivation"
        case .experience: return "Experience"
        }
    }
    
    public var otherFieldPlaceholderText: String {
        switch self {
        case .roles: return ""
        case .skills: return ""
        case .attributes: return ""
        case .universities: return ""
        case .year: return ""
        case .availabilityPeriod: return ""
        case .motivation: return ""
        case .reason: return ""
        case .experience: return ""
        }
    }
    
    public var textblockGuidance: String {
        switch self {
        case .roles:
            return ""
        case .skills:
            return ""
        case .attributes:
            return ""
        case .universities:
            return ""
        case .year:
            return ""
        case .availabilityPeriod:
            return ""
        case .motivation:
            return "Please describe what is motivating you to apply for this position"
        case .reason:
            return ""
        case .experience:
            return "Please describe what experience you have that is relevant to this position"
        }
    }
    
    public var textblockPlaceholder: String {
        switch self {

        case .roles: return ""
        case .skills: return ""
        case .attributes: return ""
        case .universities: return ""
        case .year: return ""
        case .availabilityPeriod: return ""
        case .motivation:
            return "Tip: I’m particularly interested in working with you or your company because..."
        case .reason:
            return "Tip: I’m particularly interested in working with you or your company because..."
        case .experience:
            return "Tip: My relevant experience is.. or why you should employ me"
        }
    }
}
