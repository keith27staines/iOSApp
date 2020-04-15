import Foundation
import WorkfinderCommon
import WorkfinderServices


public protocol LoginUserServiceProtocol: class {
    func loginUser(user: User, completion: @escaping((Result<String,Error>) -> Void))
}

class LoginUserService: LoginUserServiceProtocol {
    let endpoint: String
    var completion: ((Result<String,Error>) -> Void)?
    let taskHandler = TaskCompletionHandler()
    let session = URLSession(configuration: URLSessionConfiguration.default)
    var task: URLSessionDataTask?
    var user: User!
    
    func loginUser(user: User, completion: @escaping ((Result<String, Error>) -> Void)) {
        self.completion = completion
        self.user = user
        let request = makeURLRequest()
        task?.cancel()
        self.completion = completion
        task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.taskHandler.handleResult(data: data, response: response, error: error, completion: self.deserialise)
            }
        })
        task?.resume()
    }
    
    func deserialise(dataResult: Result<Data,Error>) {
        switch dataResult {
        case .success(let data):
            do {
                //let _ = try JSONDecoder().decode(UserRegistrationResponseJson.self, from: data)
                completion?(Result<String,Error>.success("token"))
            } catch {
                completion?(Result<String,Error>.failure(NetworkError.deserialization(error)))
            }
        case .failure(let error):
            completion?(Result<String,Error>.failure(error))
        }
    }
    
    func makeURLRequest() -> URLRequest {
        let components = URLComponents(string: endpoint)!
        let url = components.url!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(user)
        return request
    }
    
    public init(networkConfig: NetworkConfig) {
        self.endpoint = networkConfig.workfinderApiV3 + "auth/login/"
    }
    
}
