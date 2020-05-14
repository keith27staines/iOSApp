
import Foundation

public enum ProviderType {
    case network
    case clientTextField
    case clientTextblock
    case clientAvailabilityPeriod
}

/*
 Final Fields are:
 (FE type, number to choose)
 *         Year (pick list & 'other', 1)
 *         Subject (pick list & 'other', 1)
 *         Institution (Typeahead & 'other', 1)
 *         Placement Type (pick list, 1)
 *         Project (pick list & 'other', 1)
 *         Motivation (free text)
 *         Availability (date picker)
 *         Duration (pick list, 1)
 *         Experience (free text)
 *         Attributes (pick list, 1-3)
 *         Skills (pick list, 1-3)
 */

public enum PicklistType: Int, CaseIterable, Codable {
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
    
    /*
     {
         "companies": "http://develop.workfinder.com/v3/companies/",
         "locations": "http://develop.workfinder.com/v3/locations/",
         "hosts": "http://develop.workfinder.com/v3/hosts/",
         "associations": "http://develop.workfinder.com/v3/associations/",
         "placements": "http://develop.workfinder.com/v3/placements/",
         "candidates": "http://develop.workfinder.com/v3/candidates/",
         "pings": "http://develop.workfinder.com/v3/pings/",
         "coverletters": "http://develop.workfinder.com/v3/coverletters/",
         "institutions": "http://develop.workfinder.com/v3/institutions/",
         "placement-years-of-study": "http://develop.workfinder.com/v3/placement-years-of-study/",
         "placement-types": "http://develop.workfinder.com/v3/placement-types/",
         "placement-projects": "http://develop.workfinder.com/v3/placement-projects/",
         "placement-durations": "http://develop.workfinder.com/v3/placement-durations/",
         "placement-skills": "http://develop.workfinder.com/v3/placement-skills/",
         "placement-attributes": "http://develop.workfinder.com/v3/placement-attributes/",
         "subjects": "http://develop.workfinder.com/v3/subjects/",
         "projects": "http://develop.workfinder.com/v3/projects/",
         "project-types": "http://develop.workfinder.com/v3/project-types/"
     }
     */
    
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
        case .skills: return NSLocalizedString("skills", comment: "")
        case .attributes: return NSLocalizedString("attributes", comment: "")
        case .institutions: return NSLocalizedString("educational institution", comment: "")
        case .year: return NSLocalizedString("year", comment: "")
        case .motivation: return NSLocalizedString("motivation", comment: "")
        case .experience: return NSLocalizedString("experience", comment: "")
        case .availabilityPeriod: return NSLocalizedString("availability", comment: "")
        case .subject: return NSLocalizedString("subject", comment: "")
        case .placementType: return NSLocalizedString("placement type", comment: "")
        case .project: return NSLocalizedString("project", comment: "")
        case .duration: return NSLocalizedString("duration", comment: "")
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
            return NSLocalizedString("Select the duration of placement that you would prefer", comment: "")
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
            return "Tip: My relevant experience is.. or why you should employ me"
        case .subject: return ""
        case .placementType: return ""
        case .project: return ""
        case .duration: return ""
        }
    }
}
