import Foundation

public struct F4SDateHelper {
    static public func unformattedAcceptDateStringToFormattedString(unformattedString: String?) -> String {
        let formattedString: String
        if let unformattedString = unformattedString {
            let endDate = F4SDateHelper.yyyyMMDD(string: unformattedString)
            formattedString = endDate?.asAcceptDateString() ?? unformattedString
        } else {
            formattedString = ""
        }
        return formattedString
    }
    
    static public func yyyyMMDD(string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: string)
    }
}

public extension Date {
    func asAcceptDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter.string(from: self)
    }
}
