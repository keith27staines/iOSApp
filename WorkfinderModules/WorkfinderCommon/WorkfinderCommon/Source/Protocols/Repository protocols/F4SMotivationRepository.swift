
public enum MotivationTextOption {
    case standard
    case custom
}

public protocol F4SMotivationRepositoryProtocol {
    
    func loadMotivationType() -> MotivationTextOption
    func loadCustomMotivation() -> String
    func saveMotivationType(_ option: MotivationTextOption)
    func saveCustomMotivation(_ motivation: String)
    func loadDefaultMotivation() -> String
}

public class F4SMotivationRepository: F4SMotivationRepositoryProtocol {
    let localStore: LocalStorageProtocol
    public init(localStore: LocalStorageProtocol) {
        self.localStore = localStore
    }
    public func loadMotivationType() -> MotivationTextOption {
        guard let value = localStore.value(key: LocalStore.Key.useDefaultMotivation) as? Bool else {
            return .standard
        }
        return value ? .standard : .custom
    }
    
    public func loadDefaultMotivation() -> String {
        return NSLocalizedString("My motivation for applying is so that I can better prepare for the type of work offered by companies like yours", comment: "")
    }
    
    public func loadCustomMotivation() -> String {
        return localStore.value(key: LocalStore.Key.motivationKey) as? String ?? ""
    }
    
    public func saveMotivationType(_ option: MotivationTextOption) {
        let useDefault: Bool = option == .standard ? true : false
        localStore.setValue(useDefault, for: LocalStore.Key.useDefaultMotivation)
    }
    
    public func saveCustomMotivation(_ motivation: String) {
        localStore.setValue(motivation, for: LocalStore.Key.motivationKey)
    }
    
}
