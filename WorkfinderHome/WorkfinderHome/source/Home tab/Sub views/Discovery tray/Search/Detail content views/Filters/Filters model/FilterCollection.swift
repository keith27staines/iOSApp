
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
    
    var count: Int {
        filters.reduce(0) { (count, filter) -> Int in
            return count + (filter.isSelected ? 1 : 0)
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
            filters.append(Filter(type: FilterType.skillBusinessSales))
            filters.append(Filter(type: FilterType.skillBusinessDevelopment))
            filters.append(Filter(type: FilterType.skillCompetitorAnalysis))
            filters.append(Filter(type: FilterType.skillContentPlanning))
            filters.append(Filter(type: FilterType.skillDigitalMarketing))
            filters.append(Filter(type: FilterType.skillCustomerSegmentation))
            filters.append(Filter(type: FilterType.skillGraphicDesign))
            filters.append(Filter(type: FilterType.skillMVPBuilds))
            filters.append(Filter(type: FilterType.skillMarketAnalysis))
            filters.append(Filter(type: FilterType.skillMarketing))
            filters.append(Filter(type: FilterType.skillMarketingAnalysis))
        case .salary:
            filters.append(Filter(type: FilterType.salaryPaid))
            filters.append(Filter(type: FilterType.salaryVoluntary))
        }
    }
}
