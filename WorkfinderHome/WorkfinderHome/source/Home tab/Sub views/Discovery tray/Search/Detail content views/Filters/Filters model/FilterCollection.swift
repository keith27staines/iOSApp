
class FilterCollection {
    var isExpanded: Bool = false
    var name: FilterCollectionName { type.collectionName }
    let type: FilterCollectionType
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
        names.forEach { (name) in
            filters.append(Filter(type: FilterType(name: name, queryValue: name)))
        }
    }
    
    init(type: FilterCollectionType) {
        self.type = type
        switch type {
        case .jobType: break
        case .projectType: break
        case .skills: break
        case .salary:
            filters.append(Filter(type: FilterTypeEnum.salaryPaid))
            filters.append(Filter(type: FilterTypeEnum.salaryVoluntary))
        }
    }
}
