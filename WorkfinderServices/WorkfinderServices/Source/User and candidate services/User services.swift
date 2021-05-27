
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
    
    public func deleteAccount(completion: @escaping (Result<DeleteAccountJson,Error>) -> Void) {
        do {
            let request = try buildRequest(relativePath: "users/me/", queryItems: nil, verb: .delete)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(.failure(error))
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
                var country: Country?
            }
            var userPatch = UserPatch(
                full_name: user.fullname,
                first_name: user.firstname,
                last_name: user.lastname,
                nickname: user.firstname,
                email: user.email,
                opted_into_marketing: user.optedIntoMarketing ?? false
            )
            if let iso = user.countryOfResidence?.id {
                userPatch.country = Country(id: iso)
            }
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
        var nickname: String
        var full_name: String
        var first_name: String
        var last_name: String
        var referrer: F4SUUID?
        
        public init(user: User) {
            self.full_name = user.fullname ?? ""
            self.nickname = user.nickname ?? ""
            self.first_name = user.firstname ?? ""
            self.last_name = user.lastname ?? ""
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
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(Result<User,Error>.failure(error))
        }
    }
}
