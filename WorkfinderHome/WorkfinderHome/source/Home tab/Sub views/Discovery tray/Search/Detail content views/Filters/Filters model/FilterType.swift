
typealias FilterName = String
typealias FilterCollectionName = String
typealias FilterQueryValue = String

protocol FilterTypeProtocol {
    var name: FilterName { get }
    var queryValue: FilterQueryValue { get }
}

struct FilterType: FilterTypeProtocol {
    var name: FilterName
    var queryValue: FilterQueryValue
}

enum FilterTypeEnum: FilterTypeProtocol {
    // jop types
    case jobFullTime
    case jobPartTime
    case jobFlexible
    
    // project types - now fetched from server
    
    // skill types
    case skillApplicationTesting
    case skillBrandDesign
    case skillBusinessSales
    case skillBusinessDevelopment
    case skillCompetitorAnalysis
    case skillContentPlanning
    case skillDigitalMarketing
    case skillCustomerSegmentation
    case skillGraphicDesign
    case skillMVPBuilds
    case skillMarketAnalysis
    case skillMarketing
    case skillMarketingAnalysis
    
    // salary types
    case salaryPaid
    case salaryVoluntary
    
    var name: FilterName {
        switch self {
        case .jobFullTime: return "Full-time"
        case .jobPartTime: return "Part-time"
        case .jobFlexible: return "Flexible"
        case .skillApplicationTesting: return "Application Testing"
        case .skillBrandDesign: return "Brand Design"
        case .skillBusinessDevelopment: return "Business Development"
        case .skillCompetitorAnalysis: return "Competitor Analysis"
        case .skillContentPlanning: return "Content Planning"
        case .skillDigitalMarketing: return "Digital Marketing"
        case .salaryPaid: return "Paid"
        case .salaryVoluntary: return "Voluntary"
        case .skillBusinessSales: return "Business Sales"
        case .skillCustomerSegmentation: return "CustomerSegmentation"
        case .skillGraphicDesign: return "Graphic Design"
        case .skillMVPBuilds: return "MVP Builds"
        case .skillMarketAnalysis: return "Market Analysis"
        case .skillMarketing: return "Marketing"
        case .skillMarketingAnalysis:  return "Marketing Analysis"
        }
    }
    
    var queryValue: FilterQueryValue {
        switch self {
        case .salaryPaid: return "True"
        case .salaryVoluntary: return "False"
        default: return name
        }
    }
}
