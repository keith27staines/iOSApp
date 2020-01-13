
import Foundation

public protocol AppSettingProvider {
    func currentValue(key:AppSettingKey) -> String
}

public enum AppSettingKey: String, CaseIterable {
    
    // introduced in 2.9.0
    case displayName
    
    public var defaultValue: String {
        switch self {
        case .displayName: return "Workfinder"
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
