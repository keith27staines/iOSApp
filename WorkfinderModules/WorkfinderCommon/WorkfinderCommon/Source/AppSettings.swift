
import Foundation

public protocol AppSettingProvider {
    func currentValue(key:AppSettingKey) -> String
}

public enum AppSettingKey: String, CaseIterable {
    
    // introduced in 2.9.0
    case displayName
    
    // introduced in 2.9.0
    case ab_showHostsEnabled = "ab_show_hosts"
    
    // introduced in 2.9.1
    case ab_CompanyDetailsFirstEmphasis = "ab_CompanyDetailsFirstEmphasis"
    
    public var defaultValue: String {
        switch self {
        case .displayName: return "Workfinder"
        case .ab_showHostsEnabled: return "cannot be this value"
        case .ab_CompanyDetailsFirstEmphasis: return "company"
        }
    }

    public static var defaultsDictionary: [String: String] {
        var dictionary = [String: String]()
        AppSettingKey.allCases.forEach { (appConstant) in
            dictionary[appConstant.rawValue] = appConstant.defaultValue
        }
        return dictionary
    }
}
