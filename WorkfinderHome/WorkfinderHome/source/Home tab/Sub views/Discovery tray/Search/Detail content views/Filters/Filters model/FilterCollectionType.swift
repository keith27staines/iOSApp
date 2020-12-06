

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
