import Foundation

public protocol F4SUserRepositoryProtocol {
    func save(user: F4SUserProtocol)
    func load() -> F4SUserProtocol
}

public class F4SUserRepository : F4SUserRepositoryProtocol {
    let localStore: LocalStorageProtocol
    public init(localStore: LocalStorageProtocol = UserDefaults.standard) {
        self.localStore = localStore
    }
    
    public func save(user: F4SUserProtocol) {
        let concreteUser = F4SUser(userInformation: user)
        let data = try! JSONEncoder().encode(concreteUser)
        localStore.setValue(data, for: LocalStore.Key.user)
    }
    
    public func load() -> F4SUserProtocol {
        guard let data = localStore.value(key: LocalStore.Key.user) as? Data else { return F4SUser() }
        let user = try! JSONDecoder().decode(F4SUser.self, from: data)
        if let partnerUuid = localStore.value(key: LocalStore.Key.partnerID) as? F4SUUID {
            if user.partners == nil {
                let partnerUuidDictionary = F4SUUIDDictionary(uuid: partnerUuid)
                user.partners = [partnerUuidDictionary]
                self.save(user: user)
            }
        }
        return user
    }
    
}
