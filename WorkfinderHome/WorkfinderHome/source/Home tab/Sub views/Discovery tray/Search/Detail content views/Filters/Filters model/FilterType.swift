
typealias FilterName = String
typealias FilterCollectionName = String
typealias FilterQueryValue = String

protocol FilterTypeProtocol {
    var name: FilterName { get }
    var queryValue: FilterQueryValue { get }
}

/// Filters loaded from api use `FilterType`
struct FilterType: FilterTypeProtocol {
    var name: FilterName
    var queryValue: FilterQueryValue
}

/// Hard coded filters use `FilterTypeEnum`
enum FilterTypeEnum: FilterTypeProtocol {

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
