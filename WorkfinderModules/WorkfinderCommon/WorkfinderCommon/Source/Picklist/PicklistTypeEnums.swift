
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
}
