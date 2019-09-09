import Foundation

public protocol F4SUserRepositoryProtocol {
    func save(user: F4SUser)
    func load() -> F4SUser
}

public class F4SUserRepository : F4SUserRepositoryProtocol {
    let localStore: LocalStorageProtocol
    public init(localStore: LocalStorageProtocol = UserDefaults.standard) {
        self.localStore = localStore
    }
    
    public func save(user: F4SUser) {
        let data = try! JSONEncoder().encode(user)
        localStore.setValue(data, for: LocalStore.Key.user)
    }
    
    public func load() -> F4SUser {
        guard let data = localStore.value(key: LocalStore.Key.user) as? Data else { return F4SUser() }
        return try! JSONDecoder().decode(F4SUser.self, from: data)
    }
    
}
