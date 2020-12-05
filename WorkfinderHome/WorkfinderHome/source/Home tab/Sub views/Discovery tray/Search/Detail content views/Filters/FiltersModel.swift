
typealias FilterName = String
typealias FilterCollectionName = String
typealias FilterQueryValue = String

enum FilterCollectionType: CaseIterable {
    case jobType
    case projectType
    case skills
    case salary
    
    var collectionName: FilterCollectionName {
        switch self {
        case .jobType: return "Job type"
        case .projectType: return "Project type"
        case .skills: return "Skills"
        case .salary: return "Salary"
        }
    }
    
    var queryKey: FilterQueryValue {
        switch self {
        case .jobType: return "employment_type"
        case .projectType: return "type"
        case .skills: return "skill"
        case .salary: return "is_paid"
        }
    }
}

class FiltersModel {

    var filterCollections = [FilterCollection]()
    
    func clear() {
        filterCollections.forEach { (collection) in collection.clear() }
    }
    
    var queryString: String? {
        let params = filterCollections.reduce("") { (result, collection) -> String in
            let queryString = collection.queryString
            guard !queryString.isEmpty else { return result }
            let term = "\(collection.type.queryKey)=\(queryString)"
            guard !result.isEmpty else { return term }
            return result.appending("&\(term)")
        }
        return params.isEmpty ? nil : params
    }

    init() {
        filterCollections.append(FilterCollection(type: .jobType))
        filterCollections.append(FilterCollection(type: .projectType))
        filterCollections.append(FilterCollection(type: .skills))
        filterCollections.append(FilterCollection(type: .salary))
    }
}

class FilterCollection {
    var isExpanded: Bool = false
    var name: FilterCollectionName { type.collectionName }
    var type: FilterCollectionType
    var filters = [Filter]()
    
    var queryString: String {
        filters.reduce("") { (string, filter) -> String in
            guard filter.isSelected else { return string }
            let queryValue = filter.type.queryValue
            if string.isEmpty { return queryValue }
            return "\(string),\(queryValue)"
        }
    }
    
    func clear() {
        filters.forEach { filter in filter.isSelected = false }
    }
    
    init(type: FilterCollectionType) {
        self.type = type
        switch type {
        case .jobType:
            filters.append(Filter(type: FilterType.jobFullTime))
            filters.append(Filter(type: FilterType.jobPartTime))
            filters.append(Filter(type: FilterType.jobFlexible))
        case .projectType:
            filters.append(Filter(type: FilterType.projectApplicationTesting))
            filters.append(Filter(type: FilterType.projectBespoke))
            filters.append(Filter(type: FilterType.projectCompetitorAnalysisReview))
            filters.append(Filter(type: FilterType.projectCreativeDigitalMarketing))
            filters.append(Filter(type: FilterType.projectDesignBrandCollateral))
            filters.append(Filter(type: FilterType.projectLeadGenerationForSales))
            filters.append(Filter(type: FilterType.projectProductDevelopment))
            filters.append(Filter(type: FilterType.projectProofOfConceptBuild))
            filters.append(Filter(type: FilterType.projectUXTestingAndAnalysis))
            filters.append(Filter(type: FilterType.projectWebDesign))
        case .skills:
            filters.append(Filter(type: FilterType.skillApplicationTesting))
            filters.append(Filter(type: FilterType.skillBrandDesign))
            filters.append(Filter(type: FilterType.skillBusinessDevelopment))
            filters.append(Filter(type: FilterType.skillApplicationTesting))
            filters.append(Filter(type: FilterType.skillApplicationTesting))
            filters.append(Filter(type: FilterType.skillApplicationTesting))
            filters.append(Filter(type: FilterType.skillApplicationTesting))
            filters.append(Filter(type: FilterType.skillApplicationTesting))
            filters.append(Filter(type: FilterType.skillApplicationTesting))
            filters.append(Filter(type: FilterType.skillApplicationTesting))
            filters.append(Filter(type: FilterType.skillApplicationTesting))
            filters.append(Filter(type: FilterType.skillApplicationTesting))
            filters.append(Filter(type: FilterType.skillApplicationTesting))
        case .salary:
            filters.append(Filter(type: FilterType.salaryPaid))
            filters.append(Filter(type: FilterType.salaryVoluntary))
        }
    }
}

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
        case .salaryVoluntary: return "True"
        default: return name
        }
    }
}


class Filter {
    var type: FilterTypeProtocol
    var isSelected: Bool = false
    
    init(type: FilterTypeProtocol) {
        self.type = type
    }
}

