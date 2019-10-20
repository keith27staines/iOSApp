
import Foundation
import Firebase
import FirebaseRemoteConfig

public class MockAppSettingProvider: AppSettingProvider {
    public static func currentValue(key: AppSettingKey) -> String {
        return key.defaultValue
    }
}

public protocol AppSettingProvider {
    static func currentValue(key:AppSettingKey) -> String
}

public enum AppSettingKey: String, CaseIterable {
    
    case displayName
    case showHostsEnabled = "show_hosts_enabled"
    
    var defaultValue: String {
        switch self {
        case .displayName: return "Workfinder"
        case .showHostsEnabled: return "false"
        }
    }

    static var defaultsDictionary: [String: String] {
        var dictionary = [String: String]()
        AppSettingKey.allCases.forEach { (appConstant) in
            dictionary[appConstant.rawValue] = appConstant.defaultValue
        }
        return dictionary
    }
}

extension AppSettingKey: AppSettingProvider {
    public static func currentValue(key:AppSettingKey) -> String {
        return RemoteConfig.remoteConfig().configValue(forKey: key.rawValue).stringValue ?? key.defaultValue
    }
}


class RemoteConfiguration {

    let remoteConfig: RemoteConfig
    
    init() {
        remoteConfig = RemoteConfig.remoteConfig()
    }
    
    func start() {
        InstanceID.instanceID().instanceID { (result, error) in
            guard let result = result else { return }
            print("Remote instance ID token: \(result.token)")
        }
        loadDefaultValues()
        fetchCloudValues()
    }
    
    private func loadDefaultValues() {
        remoteConfig.setDefaults(AppSettingKey.defaultsDictionary as [String: NSObject])
    }
    
    private func fetchCloudValues() {
        remoteConfig.fetchAndActivate { (status, error) in
            guard error == nil else { return }
            print(AppSettingKey.currentValue(key: AppSettingKey.showHostsEnabled))
        }
    }
    
}
