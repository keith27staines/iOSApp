
typealias FilterName = String
typealias FilterCollectionName = String
typealias FilterQueryValue = String

protocol FilterTypeProtocol {
    var name: FilterName { get }
    var queryValue: FilterQueryValue { get }
}

enum FilterType: FilterTypeProtocol {
    // jop types
    case jobFullTime
    case jobPartTime
    case jobFlexible
    
    // project types
    case projectApplicationTesting
    case projectBespoke
    case projectCompetitorAnalysisReview
    case projectCreativeDigitalMarketing
    case projectDesignBrandCollateral
    case projectLeadGenerationForSales
    case projectProductDevelopment
    case projectProofOfConceptBuild
    case projectUXTestingAndAnalysis
    case projectWebDesign
    
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
        case .projectApplicationTesting: return "Application Testing"
        case .projectBespoke: return "Bespoke"
        case .projectCompetitorAnalysisReview: return "Competitor Analysis Review"
        case .projectCreativeDigitalMarketing: return "Creative Digital Marketing"
        case .projectDesignBrandCollateral: return "Brand Collateral"
        case .projectLeadGenerationForSales: return "Lead Generation For Sales"
        case .projectProductDevelopment: return "Product Development"
        case .projectProofOfConceptBuild: return "Proof Of Concept Build"
        case .projectUXTestingAndAnalysis: return "UX Testing And Analysis"
        case .projectWebDesign: return "Web Design"
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
