
import Foundation

public protocol AppSettingProvider {
    func currentValue(key:AppSettingKey) -> String
}

public enum AppSettingKey: String, CaseIterable {
    
    // introduced in 2.9.0
    case displayName
    
    // ab test introduced in 2.10
    case ab_companyDetail_presentation_mode
    
    public var defaultValue: String {
        switch self {
        case .displayName: return "Workfinder"
        case .ab_companyDetail_presentation_mode: return "showTabs == true, first == company"
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
