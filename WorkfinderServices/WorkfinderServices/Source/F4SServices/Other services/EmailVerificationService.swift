import Foundation
import WorkfinderCommon

typealias URLDataTaskCompletion = ((Data?, URLResponse?, Error?) -> Void)

public class EmailVerificationService : EmailVerificationServiceProtocol {
    
    let configuration: NetworkConfig
    let startUrlString = "https://founders4schools.eu.auth0.com/passwordless/start"
    let verifyUrlString = "https://founders4schools.eu.auth0.com/oauth/ro"
    var task: F4SNetworkTask?
    var taskfactory: ((URLRequest, @escaping URLDataTaskCompletion) -> F4SNetworkTask) = { request, result in
        return URLSession.shared.dataTask(with: request, completionHandler: result)
    }
    
    public init(configuration: NetworkConfig) {
        self.configuration = configuration
    }
    
    public func cancel() {
        task?.cancel()
    }
    
    public func start(email: String,
                      clientId: String,
                      onSuccess: @escaping (_ email:String) -> Void,
                      onFailure: @escaping (_ email:String, _ clientId:String, _ error:EmailSubmissionError) -> Void) {
        
        let payload = StartPayload(email: email, client_id: clientId)
        let payloadData = try! JSONEncoder().encode(payload)
        let request = prepareRequest(urlString: startUrlString, method: "POST", bodyData: payloadData)
        let taskCompletion: URLDataTaskCompletion = { (data, response, error) in
            DispatchQueue.main.async { [ weak self] in
                self?.logResult(attempting: "Start email verification",
                                request: request,
                                data: data,
                                response: response,
                                error: error)
                if let _ = error { onFailure(email, clientId, EmailSubmissionError.client) ; return }
                let statusCode = (response as! HTTPURLResponse).statusCode
                let submissionError = EmailSubmissionError.emailSubmissionError(from: statusCode)
                guard submissionError == nil else {onFailure(email, clientId, submissionError!) ;  return }
                onSuccess(email)
            }
        }
        task?.cancel()
        task = taskfactory(request, taskCompletion)
        task?.resume()
    }
    
    func logResult(attempting: String, request: URLRequest, data: Data?, response: URLResponse?, error: Error?) {
        let httpResponse = response as? HTTPURLResponse
        let logger = configuration.logger
        if let error = error {
            logger.logDataTaskFailure(attempting: attempting, error: error, request: request, response: httpResponse, responseData: data)
            return
        }
        if data == nil {
            let networkError = F4SNetworkError(response: httpResponse!, attempting: attempting)!
            logger.logDataTaskFailure(attempting: attempting, error: networkError, request: request, response: httpResponse, responseData: data)
            return
        }
        logger.logDataTaskSuccess(request: request, response: httpResponse!, responseData: data!)
    }
    
    public func verifyWithCode(email: String, code: String, onSuccess: @escaping  ( _ email:String) -> Void, onFailure: @escaping (_ email:String, _ error:CodeValidationError) -> Void) {
        let payload = VerifyPayload(username: email, password: code)
        let payloadData = try! JSONEncoder().encode(payload)
        let request = prepareRequest(urlString: verifyUrlString, method: "POST", bodyData: payloadData)
        let taskCompletion: URLDataTaskCompletion = { (data, response, error) in
            DispatchQueue.main.async { [ weak self] in
                self?.logResult(attempting: "Verify with code", request: request, data: data, response: response, error: error)
                if let _ = error { onFailure(email, CodeValidationError.client) ; return }
                let statusCode = (response as! HTTPURLResponse).statusCode
                let verificationError = CodeValidationError.codeValidationError(from: statusCode)
                guard verificationError == nil else { onFailure(email, verificationError!) ; return }
                onSuccess(email)
            }
        }
        task?.cancel()
        task = taskfactory(request, taskCompletion)
        task?.resume()
    }
    
    func prepareRequest(urlString: String, method: String, bodyData: Data) -> URLRequest {
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(base64EncodedTelemeteryValue(), forHTTPHeaderField: "Auth0-Client")
        request.httpBody = bodyData
        return request
    }
    
    func base64EncodedTelemeteryValue() -> String {
        let data = try! JSONEncoder().encode(Telemetery())
        return data.base64EncodedString()
    }
}

struct PasswordlessResponse : Decodable {
    let _id: String
    let email: String
    let email_verified: Bool
}

struct Telemetery : Codable {
    let name = "Auth0.swift"
    let version = "1.9.2"
    let swiftVersion = "3.0"
    private enum CodingKeys : String, CodingKey {
        case name
        case version
        case swiftVersion = "swift-version"
    }
}

struct StartPayload : Encodable {
    let email: String
    let connection = "email"
    let send = "link_ios"
    var client_id: String
}

struct VerifyPayload : Encodable {
    var username: String
    var password: String
    let connection = "email"
    let grant_type = "password"
    let client_id = "2LfjThv1qvdIZn7L09v5OwxhsW87k4Hf"
    let scope = "openid email"
}
