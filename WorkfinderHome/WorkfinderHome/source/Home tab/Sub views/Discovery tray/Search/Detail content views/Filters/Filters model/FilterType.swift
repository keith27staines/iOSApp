
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
    // jop types - now fetched from server

    // project types - now fetched from server

    // skill types - now fetched from server
    
    // salary types
    case salaryPaid
    case salaryVoluntary
    
    var name: FilterName {
        switch self {
        case .salaryPaid: return "Paid"
        case .salaryVoluntary: return "Voluntary"
        }
    }
    
    var queryValue: FilterQueryValue {
        switch self {
        case .salaryPaid: return "True"
        case .salaryVoluntary: return "False"
        }
    }
}
