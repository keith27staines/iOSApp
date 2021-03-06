
import Foundation
import WorkfinderCommon

public protocol RegisterUserServiceProtocol: AnyObject {
    func registerUser(user: User, completion: @escaping((Result<UserRegistrationToken,Error>) -> Void) )
}

public protocol SignInUserServiceProtocol: AnyObject {
    func signIn(user: User, completion: @escaping((Result<UserRegistrationToken,Error>) -> Void))
}

public class SignInUserService: WorkfinderService, SignInUserServiceProtocol {
    public func signIn(user: User, completion: @escaping((Result<UserRegistrationToken,Error>) -> Void)) {
        do {
            let body = [
                "email": user.email,
                "password": user.password
            ]
            let request = try buildRequest(relativePath: "auth/login/", verb: .post, body: body)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(Result<UserRegistrationToken,Error>.failure(error))
        }
    }
}

public class UpdateUserService: WorkfinderService {
    
    public func deleteAccount(email: String, completion: @escaping (Result<DeleteAccountJson,Error>) -> Void) {
        do {
            let body = ["email":email]
            let request = try buildRequest(relativePath: "users/me/", verb: .delete, body: body)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(.failure(error))
        }
    }
    
    public func updateUserName(firstName: String, lastName: String, completion: @escaping (Result<User,Error>) -> Void) {
        struct UserPatch: Codable {
            var first_name: String
            var last_name: String
        }
        let userPatch = UserPatch(
            first_name: firstName,
            last_name: lastName
        )
        do {
            let request = try buildRequest(relativePath: "users/me/", verb: .patch, body: userPatch)
            performTask(with: request, verbose: true, completion: completion, attempting: #function)
        } catch {
            completion(Result<User,Error>.failure(error))
        }
    }
    
    public func updateUser(user: User, completion: @escaping((Result<User,Error>) -> Void) ) {
        do {
            struct UserPatch: Codable {
                var full_name: String?
                var first_name: String?
                var last_name: String?
                var nickname: String?
                var email: String?
                var opted_into_marketing: Bool
                var country: String?
            }
            let userPatch = UserPatch(
                full_name: user.fullname,
                first_name: user.firstname,
                last_name: user.lastname,
                nickname: user.firstname,
                email: user.email,
                opted_into_marketing: user.optedIntoMarketing ?? false,
                country: user.countryOfResidence ?? ""
            )
            let request = try buildRequest(relativePath: "users/me/", verb: .patch, body: userPatch)
            performTask(with: request, verbose: true, completion: completion, attempting: #function)
        } catch {
            completion(Result<User,Error>.failure(error))
        }
    }
}

public class RegisterUserService: WorkfinderService, RegisterUserServiceProtocol {
    
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
        var referrer: F4SUUID?
        
        public init(user: User) {

            self.email = user.email ?? ""
            self.password1 = user.password ?? ""
            self.password2 = user.password ?? ""
        }
    }
}

public protocol FetchMeProtocol {
    func fetch(completion: @escaping((Result<User,Error>) -> Void) )
}

public class FetchMeService: WorkfinderService, FetchMeProtocol {
    
    public func fetch(completion: @escaping((Result<User,Error>) -> Void) ) {
        do {
            let request = try buildRequest(relativePath: "users/me", queryItems: [], verb: .get)
            performTask(with: request, verbose: true, completion: completion, attempting: #function)
        } catch {
            completion(Result<User,Error>.failure(error))
        }
    }
}
