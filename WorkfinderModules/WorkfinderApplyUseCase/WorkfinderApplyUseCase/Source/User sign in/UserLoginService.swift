import Foundation
import WorkfinderCommon
import WorkfinderServices


public protocol LoginUserServiceProtocol: class {
    func loginUser(user: User, completion: @escaping((Result<String,Error>) -> Void))
}

class LoginUserService: WorkfinderService, LoginUserServiceProtocol {
    
    func loginUser(user: User, completion: @escaping ((Result<String, Error>) -> Void)) {
        do {
            let request = try buildLoginUserRequest(user: user)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(Result<String, Error>.failure(error))
        }
    }

    func buildLoginUserRequest(user: User) throws -> URLRequest {
        return try buildRequest(
            relativePath: "auth/login/",
            verb: .post,
            body: user)
    }
    
}
