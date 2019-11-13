
import Foundation

public class MockAppSettingProvider: AppSettingProvider {
    public func currentValue(key: AppSettingKey) -> String {
        return key.defaultValue
    }
    
    public init() {}
}
