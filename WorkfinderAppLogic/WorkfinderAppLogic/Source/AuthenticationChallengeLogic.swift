
import WorkfinderCommon

public class AuthenticationChallengeLogic {
    
    let userRepository: UserRepositoryProtocol
    
    
    public var tokenExists: Bool {
        guard let token = userRepository.loadAccessToken() else { return false }
        return token.isEmpty == false
    }
    
    public var email: String? { return userRepository.loadUser().email }
    
    public var password: String? { return userRepository.loadUser().password }
    
    public func handle401() {
        
    }
    
    public init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
}
