
import Foundation
import Firebase
import FirebaseRemoteConfig
import WorkfinderCommon

class RemoteConfiguration: AppSettingProvider {

    let remoteConfig: RemoteConfig
    
    init() {
        remoteConfig = RemoteConfig.remoteConfig()
    }
    
    func start() {
        InstanceID.instanceID().instanceID { (result, error) in
            guard let result = result else { return }
            print("")
            print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")
            print("Remote instance ID token: \(result.token)")
            print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")
            print("")
        }
        loadDefaultValues()
        fetchCloudValues()
    }
    
    private func loadDefaultValues() {
        remoteConfig.setDefaults(AppSettingKey.defaultsDictionary as [String: NSObject])
    }
    
    private func fetchCloudValues() {
        let expiration: TimeInterval = Config.environment == .staging ? 0 : 12 * 3600
        remoteConfig.fetch(withExpirationDuration: expiration) { (status, error) in
            guard error == nil else { return }
            self.remoteConfig.activate { (error) in
                
            }
        }
    }
    
    public func currentValue(key:AppSettingKey) -> String {
        return remoteConfig.configValue(forKey: key.rawValue).stringValue ?? key.defaultValue
    }
    
}
