import Foundation

public enum F4SHoursType : String {
    case am = "am"
    case pm = "pm"
    case all = "all"
    case custom
    
    public var titledDisplayText: String {
        switch self {
        case .am:
            return "AM"
        case .pm:
            return "PM"
        case .all:
            return "All day"
        case .custom:
            return "custom"
        }
    }
}
