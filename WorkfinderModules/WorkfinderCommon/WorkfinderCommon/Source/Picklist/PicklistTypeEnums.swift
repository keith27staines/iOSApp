
import Foundation

public enum ProviderType {
    case network
    case clientTextField
    case clientTextblock
    case clientAvailabilityPeriod
}

public enum PicklistType: Int, CaseIterable {
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
            return NSLocalizedString("your motivation", comment: "")
        case .reason:
            return NSLocalizedString("your reason for applying", comment: "")
        case .experience:
            return NSLocalizedString("Your experience", comment: "")
        }
    }
    
    public var otherFieldGuidanceText: String {
        switch self {
        case .roles: return "Guidance for 'other' roles"
        case .skills: return "Guidance for 'other' skills"
        case .attributes: return "Guidance for 'other' attributes"
        case .universities: return "Guidance for 'other' universities"
        case .year: return "Guidance for 'other' year"
        case .availabilityPeriod: return "Guidance for 'other' availability"
        case .motivation: return "Guidance for 'other' motivation"
        case .reason: return "Guidance for 'other' reason"
        case .experience: return "Guidance for 'other' experience"
        }
    }
    
    public var otherFieldPlaceholderText: String {
        switch self {
        case .roles: return "Placeholder text for 'other' roles"
        case .skills: return "Placeholder text for 'other' skills"
        case .attributes: return "Placeholder text for 'other' attributes"
        case .universities: return "Placeholder text for 'other' universities"
        case .year: return "Placeholder text for 'other' year"
        case .availabilityPeriod: return "Placeholder text for 'other' availability"
        case .motivation: return "Placeholder text for 'other' motivation"
        case .reason: return "Placeholder text for 'other' reason"
        case .experience: return "Placeholder text for 'other' experience"
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
            return "My motivation for seeking work experience is..."
        case .reason:
            return "I’m particularly interested in working with you or your company because..."
        case .experience:
            return "My relevant experience is... or why you should consider me"
        }
    }
}
