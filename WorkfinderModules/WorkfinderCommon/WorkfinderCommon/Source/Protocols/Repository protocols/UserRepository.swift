import Foundation

public protocol UserRepositoryProtocol {
    func saveCandidate(_ candidate: Candidate)
    func saveUser(_ user: User)
    func loadCandidate() -> Candidate
    func loadUser() -> User
    func loadAccessToken() -> String?
    func saveAccessToken(_ token: String)
    var isCandidateLoggedIn: Bool { get }
}

public class UserRepository : UserRepositoryProtocol {
    let localStore: LocalStorageProtocol
    
    public var isCandidateLoggedIn: Bool {
        guard let token = loadAccessToken(), !token.isEmpty
        else { return false }
        return true
    }
    public init(localStore: LocalStorageProtocol = UserDefaults.standard) {
        self.localStore = localStore
    }
    
    public func saveCandidate(_ candidate: Candidate) {
        let data = try! JSONEncoder().encode(candidate)
        localStore.setValue(data, for: LocalStore.Key.candidate)
    }
    
    public func saveUser(_ user: User) {
        let data = try! JSONEncoder().encode(user)
        localStore.setValue(data, for: LocalStore.Key.user)
    }
    
    public func loadCandidate() -> Candidate {
        guard let data = localStore.value(key: LocalStore.Key.candidate) as? Data else { return Candidate() }
        return try! JSONDecoder().decode(Candidate.self, from: data)
    }
    
    public func loadUser() -> User {
        guard let data = localStore.value(key: LocalStore.Key.user) as? Data else { return User() }
        return try! JSONDecoder().decode(User.self, from: data)
    }
    
    public func loadAccessToken() -> String? {
        return localStore.value(key: LocalStore.Key.accessToken) as? String
    }
    
    public func saveAccessToken(_ token: String) {
        localStore.setValue(token, for: LocalStore.Key.accessToken)
    }
    
}
