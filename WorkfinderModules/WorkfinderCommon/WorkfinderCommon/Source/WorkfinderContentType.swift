import Foundation

public enum ExternalLinkOpenMode {
    case inWorkfinder
    case inBrowser
}

/// Enumeration of the different types of content hosted by the workfinder server
/// that may be displayed by the Workfinder apps
public enum WorkfinderContentType: String, Codable {
    case about
    case faqs
    case terms
    case privacyPolicy
    case offerWorkExperience
    case changePassword
    case whatMakesGoodFeedback
    
    public var title: String {
        switch self {
        case .about: return "About Workfinder"
        case .faqs: return "Frequently Asked Questions"
        case .terms: return "Terms and Conditions"
        case .privacyPolicy: return "Privacy Policy"
        case .offerWorkExperience: return ""
        case .changePassword: return ""
        case .whatMakesGoodFeedback: return "Good feedback"
        }
    }
    
    public var url: URL {
        switch self {
        case .about: return URL(string: "https://workfinder.com/about")!
        case .faqs:  return URL(string: "https://workfinder.com/faqs")!
        case .terms: return URL(string: "https://workfinder.com/terms-and-conditions")!
        case .privacyPolicy: return URL(string: "https://workfinder.com/privacy")!
        case .offerWorkExperience: return URL(string: "https://workfinder.com/employers")!
        case .changePassword: return URL(string: "https://workfinder.com/auth/password/reset/")!
        case .whatMakesGoodFeedback: return URL(string: "https://workfinder.com/about")!
        }
    }
    
    public var openingMode: ExternalLinkOpenMode {
        switch self {
        case .about: return .inWorkfinder
        case .faqs: return .inWorkfinder
        case .terms: return .inWorkfinder
        case .privacyPolicy: return .inWorkfinder
        case .offerWorkExperience: return .inBrowser
        case .changePassword: return .inWorkfinder
        case .whatMakesGoodFeedback: return .inWorkfinder
        }
    }
}
