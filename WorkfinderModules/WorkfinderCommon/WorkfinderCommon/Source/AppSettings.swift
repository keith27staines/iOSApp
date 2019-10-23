
import Foundation

public protocol AppSettingProvider {
    func currentValue(key:AppSettingKey) -> String
}

public enum AppSettingKey: String, CaseIterable {
    
    // introduced in 2.9.0
    case displayName
    
    // introduced in 2.9.0
    case showHostsEnabled = "ab_show_hosts"
    
    public var defaultValue: String {
        switch self {
        case .displayName: return "Workfinder"
        case .showHostsEnabled: return "cannot be this value"
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
