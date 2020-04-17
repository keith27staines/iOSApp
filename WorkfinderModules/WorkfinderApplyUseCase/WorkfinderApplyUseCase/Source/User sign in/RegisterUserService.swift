
import Foundation
import WorkfinderCommon
import WorkfinderServices

public struct UserRegistrationToken: Codable {
    public let key: String
}

public protocol RegisterUserServiceProtocol: class {
    func registerUser(user: User, completion: @escaping((Result<UserRegistrationToken,Error>) -> Void) )
}

class RegisterUserService: RegisterUserServiceProtocol {
    
    let taskHandler = DataTaskCompletionHandler()
    let endpoint: String
    var session: URLSession { return networkConfig.sessionManager.interactiveSession }
    var task: URLSessionDataTask?
    var user: User!
    let networkConfig: NetworkConfig
    
    public init(networkConfig: NetworkConfig) {
        self.networkConfig = networkConfig
        self.endpoint = networkConfig.workfinderApiV3 + "auth/registration/"
    }
    
    var completion: ((Result<UserRegistrationToken,Error>) -> Void)?
    
    public func registerUser(user: User, completion: @escaping((Result<UserRegistrationToken,Error>) -> Void) ) {
        task?.cancel()
        self.user = user
        let request = buildURLRequest()
        self.completion = completion
        task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.taskHandler.convertToDataResult(
                    data: data,
                    response: response,
                    error: error,
                    completion: self.deserialise)
            }
        })
        task?.resume()
    }
    
    func deserialise(dataResult: Result<Data,Error>) {
        switch dataResult {
        case .success(let data):
            do {
                let json = try JSONDecoder().decode(UserRegistrationToken.self, from: data)
                completion?(Result<UserRegistrationToken,Error>.success(json))
            } catch {
                completion?(Result<UserRegistrationToken,Error>.failure(NetworkError.deserialization(error)))
            }
        case .failure(let error):
            completion?(Result<UserRegistrationToken,Error>.failure(error))
        }
    }
    
    func buildURLRequest() -> URLRequest {
        let components = URLComponents(string: endpoint)!
        let url = components.url!
        let jsonBody = UserRegistrationRequestJson(user: user)
        return networkConfig.buildUrlRequest(
            url: url,
            verb: .post,
            body: try! JSONEncoder().encode(jsonBody))
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
