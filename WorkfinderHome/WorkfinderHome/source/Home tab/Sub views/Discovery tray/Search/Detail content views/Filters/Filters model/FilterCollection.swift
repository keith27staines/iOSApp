
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
    
    func addFilters(with names: [String]) {
        self.type = .projectType
        names.forEach { (name) in
            filters.append(Filter(type: FilterType(name: name, queryValue: name)))
        }
    }
    
    init(type: FilterCollectionType) {
        self.type = type
        switch type {
        case .jobType:
            filters.append(Filter(type: FilterTypeEnum.jobFullTime))
            filters.append(Filter(type: FilterTypeEnum.jobPartTime))
            filters.append(Filter(type: FilterTypeEnum.jobFlexible))
        case .projectType:
            break
        case .skills:
            filters.append(Filter(type: FilterTypeEnum.skillApplicationTesting))
            filters.append(Filter(type: FilterTypeEnum.skillBrandDesign))
            filters.append(Filter(type: FilterTypeEnum.skillBusinessSales))
            filters.append(Filter(type: FilterTypeEnum.skillBusinessDevelopment))
            filters.append(Filter(type: FilterTypeEnum.skillCompetitorAnalysis))
            filters.append(Filter(type: FilterTypeEnum.skillContentPlanning))
            filters.append(Filter(type: FilterTypeEnum.skillDigitalMarketing))
            filters.append(Filter(type: FilterTypeEnum.skillCustomerSegmentation))
            filters.append(Filter(type: FilterTypeEnum.skillGraphicDesign))
            filters.append(Filter(type: FilterTypeEnum.skillMVPBuilds))
            filters.append(Filter(type: FilterTypeEnum.skillMarketAnalysis))
            filters.append(Filter(type: FilterTypeEnum.skillMarketing))
            filters.append(Filter(type: FilterTypeEnum.skillMarketingAnalysis))
        case .salary:
            filters.append(Filter(type: FilterTypeEnum.salaryPaid))
            filters.append(Filter(type: FilterTypeEnum.salaryVoluntary))
        }
    }
}
