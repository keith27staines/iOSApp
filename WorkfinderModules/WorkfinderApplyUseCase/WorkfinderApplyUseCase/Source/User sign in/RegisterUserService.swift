
import Foundation
import WorkfinderCommon
import WorkfinderServices

public struct UserRegistrationToken: Codable {
    public let key: String
}

public protocol RegisterUserServiceProtocol: class {
    func registerUser(user: User, completion: @escaping((Result<UserRegistrationToken,Error>) -> Void) )
}

class RegisterUserService: WorkfinderService, RegisterUserServiceProtocol {
    
    public func registerUser(user: User, completion: @escaping((Result<UserRegistrationToken,Error>) -> Void) ) {
        do {
            let request = try buildRequest(user: user)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(Result<UserRegistrationToken,Error>.failure(error))
        }
    }
    
    func buildRequest(user: User) throws -> URLRequest {
        return try buildRequest(
            relativePath: "auth/registration/",
            verb: .post,
            body: UserRegistrationRequestJson(user: user))
    }
    
    struct UserRegistrationRequestJson: Codable {
        var email: String
        var password1: String
        var password2: String
        var nickname: String
        var full_name: String
        var referrer: F4SUUID?
        
        public init(user: User) {
            self.full_name = user.fullname!
            self.nickname = user.nickname!
            self.email = user.email!
            self.password1 = user.password!
            self.password2 = user.password!
        }
    }
}
