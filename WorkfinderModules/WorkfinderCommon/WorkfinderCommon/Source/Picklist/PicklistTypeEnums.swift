
import Foundation

public enum ProviderType {
    case network
    case clientTextField
    case clientTextblock
    case clientAvailabilityPeriod
}

public enum PicklistType: Int, CaseIterable, Codable {
    
    /* This is the order from current production release 3.0.3
     0: case year
     1: case subject
     2: case institutions
     3: case placementType
     4: case project
     5: case motivation
     6: case availabilityPeriod
     7: case duration
     8: case experience
     9: case attributes
     10: case skills
     */
    
    case year
    case subject
    case institutions
    case placementType
    case project
    case motivation
    case availabilityPeriod
    case duration
    case experience
    case attributes
    case skills
    
    public var providerType: ProviderType {
        switch self {
        case .year,
             .subject,
             .institutions,
             .placementType,
             .project,
             .duration,
             .attributes,
             .skills: return .network
        case .motivation,
             .experience: return .clientTextField
        case .availabilityPeriod: return .clientAvailabilityPeriod
        }
    }
    
    public var isPresentationOptionalWhenPopulated: Bool {
        switch self {
        case .motivation: return false
        case .experience: return false
        default: return true
        }
    }
    
    public var presentationValueShouldBeLowercased: Bool {
        switch self {
        case .year: return true
        case .subject: return false
        case .institutions: return false
        case .placementType: return true
        case .project: return true
        case .motivation: return false
        case .availabilityPeriod: return false
        case .duration: return false
        case .experience: return false
        case .attributes: return true
        case .skills: return true
        }
    }
        
    public var endpoint: String {
        switch self {
        case .year: return "placement-years-of-study/"
        case .subject: return "subjects/"
        case .institutions: return "institutions/"
        case .placementType: return "placement-types/"
        case .project: return "placement-projects/"
        case .motivation: return ""
        case .availabilityPeriod: return ""
        case .duration: return "placement-durations/"
        case .experience: return ""
        case .attributes: return "placement-attributes/"
        case .skills: return "placement-skills/"
        }
    }
    
    public var title: String {
        switch self {
        case .skills: return "skills"
        case .attributes: return "attributes"
        case .institutions: return "university"
        case .year: return "year of study"
        case .motivation: return "Motivation"
        case .experience: return "Experience"
        case .availabilityPeriod: return "availability period"
        case .subject: return "subject"
        case .placementType: return "placement type"
        case .project: return "project"
        case .duration: return "duration"
        }
    }
    
    public var questionTitle: String {
        switch self {
        case .skills:               return "What three skills would you like to develop?"
        case .attributes:           return "What are your three best attributes?"
        case .institutions:         return "What is the name of your university?"
        case .year:                 return "What is your year of study?"
        case .motivation:           return "What is your motivation?"
        case .experience:           return "What is your relevant experience?"
        case .availabilityPeriod:   return "What is your availability?"
        case .subject:              return "What is your discipline?"
        case .placementType:        return "What type of placement?"
        case .project:              return "What kind of project?"
        case .duration:             return "How long should the placement be?"
        }
    }
    
    public var maxItems: Int {
        switch self {
        case .skills, .attributes: return 3
        case .availabilityPeriod: return 2
        default: return 1
        }
    }
    
    public var isOtherable: Bool {
        switch self {
        case .year, .subject, .project: return true
        default: return false
        }
    }
    
    public var userInstruction: String {
        switch self {
        case .skills:
            return NSLocalizedString("Choose up to three employment skills you are hoping to acquire through this Work Experience placement", comment: "")
        case .attributes:
            return NSLocalizedString("Select up to three personal attributes that describe you", comment: "")
        case .institutions:
            return NSLocalizedString("Select the university you are currently attending", comment: "")
        case .year:
            return NSLocalizedString("Select your year of study", comment: "")
        case .availabilityPeriod:
            return NSLocalizedString("Select your availability", comment: "")
        case .motivation:
            return NSLocalizedString("Your motivation", comment: "")
        case .experience:
            return NSLocalizedString("Your relevant experience", comment: "")
        case .subject:
            return NSLocalizedString("Select your main subject of study", comment: "")
        case .placementType:
            return NSLocalizedString("Select the type of placement you are looking for", comment: "")
        case .project:
            return NSLocalizedString("Select the kind of project you would prefer to work on", comment: "")
        case .duration:
            return NSLocalizedString("Select your preferred duration of placement", comment: "")
        }
    }
    
    public var otherEditorTitle: String {
        switch self {
        case .skills: return ""
        case .attributes: return ""
        case .institutions: return "Other institution"
        case .year: return "Other year"
        case .availabilityPeriod: return ""
        case .motivation: return "Motivation"
        case .experience: return "Experience"
        case .subject: return "Other subject"
        case .placementType: return "Other type"
        case .project: return "Other project"
        case .duration: return "Other duration"
        }
    }
    
    public var otherFieldPlaceholderText: String {
        switch self {
        case .skills: return ""
        case .attributes: return ""
        case .institutions: return ""
        case .year: return ""
        case .availabilityPeriod: return ""
        case .motivation: return ""
        case .experience: return ""
        case .subject: return ""
        case .placementType: return ""
        case .project: return ""
        case .duration: return ""
        }
    }
    
    public var otherFieldGuidanceText: String {
        let things: String
        switch self {
        case .skills: things = ""
        case .attributes: things = ""
        case .institutions: things = "educational institutions"
        case .year: things = "study years"
        case .availabilityPeriod: things = ""
        case .motivation: things = ""
        case .experience: things = ""
        case .subject: things = "main study subjects"
        case .placementType: return ""
        case .project: return "projects"
        case .duration: return "placement durations"
        }
        return "You selected 'Other' from our list of \(things). Please give more details below."
    }
    
    public var textBlockEditorTitle: String {
        switch self {
        case .skills: return ""
        case .attributes: return ""
        case .institutions: return ""
        case .year: return ""
        case .availabilityPeriod: return ""
        case .motivation: return "Motivation"
        case .experience: return "Experience"
        case .subject: return ""
        case .placementType: return ""
        case .project: return ""
        case .duration: return ""
        }
    }
    
    public var textblockGuidance: String {
        switch self {
        case .skills: return ""
        case .attributes: return ""
        case .institutions: return ""
        case .year: return ""
        case .availabilityPeriod: return ""
        case .motivation: return "Please describe what is motivating you to apply for this position"
        case .experience: return "Please describe what experience you have that is relevant to this position"
        case .subject: return ""
        case .placementType: return ""
        case .project: return ""
        case .duration: return ""
        }
    }
    
    public var textblockPlaceholder: String {
        switch self {
        case .skills: return ""
        case .attributes: return ""
        case .institutions: return ""
        case .year: return ""
        case .availabilityPeriod: return ""
        case .motivation:
            return "Tip: I’m particularly interested in working with you or your company because..."
        case .experience:
            return "Tip: My relevant experience is... or why you should employ me"
        case .subject: return ""
        case .placementType: return ""
        case .project: return ""
        case .duration: return ""
        }
    }
    /*
     '01' - University,
     '02' - Year Of Study,
     '03' - Discipline,
     '04' - Motivation,
     '05' Experience,
     '06' - Skills,
     '07' - Attributes
     */
    public var trackingNumber: String {
        switch self {
            
        case .year:                 return "02"
        case .subject:              return "03"
        case .institutions:         return "01"
        case .placementType:        return ""
        case .project:              return ""
        case .motivation:           return "04"
        case .availabilityPeriod:   return ""
        case .duration:             return ""
        case .experience:           return "05"
        case .attributes:           return "07"
        case .skills:               return "06"
        }
    }
}
