//
//  EmailVerificationService.swift
//  WorkfinderNetworking
//
//  Created by Keith Dev on 07/06/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

public class EmailVerificationService {
    public let email: String
    
    let startUrlString = "https://founders4schools.eu.auth0.com/passwordless/start"
    let verifyUrlString = "https://founders4schools.eu.auth0.com/oauth/ro"
    let startClientId: String
    var task: F4SNetworkTask?
    
    public init(email: String, clientId: String) {
        self.email = email
        self.startClientId = clientId
    }
    
    public enum EmailSubmissionError : Error {
        case client
        case cientsideEmailFormatCheckFailed
        case serversideEmailFormatCheckFailed
        case networkError(Int)
        
        static func emailSubmissionError(from httpStatusCode: Int) -> EmailSubmissionError? {
            guard httpStatusCode != 200 else { return nil }
            switch httpStatusCode {
            case 400: return EmailSubmissionError.serversideEmailFormatCheckFailed
            default: return networkError(httpStatusCode)
            }
        }
    }
    
    public enum CodeValidationError : Error {
        case client
        case codeEmailCombinationNotValid
        case emailNotTheSame
        case networkError(Int)
        
        static func codeValidationError(from httpStatusCode: Int) -> CodeValidationError? {
            guard httpStatusCode != 200 else { return nil }
            switch httpStatusCode {
            case 401: return CodeValidationError.codeEmailCombinationNotValid
            default: return CodeValidationError.networkError(httpStatusCode)
            }
        }
    }
    
    public func cancel() {
        task?.cancel()
    }
    
    
    public func start(onSuccess: @escaping (_ email:String) -> Void, onFailure: @escaping (_ email:String, _ error:EmailSubmissionError) -> Void) {
        let email = self.email
        let payload = makeStartPayload(email: email)
        let payloadData = try! JSONEncoder().encode(payload)
        let request = prepareRequest(urlString: startUrlString, method: "POST", bodyData: payloadData)
        task?.cancel()
        task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async { [ weak self] in
                self?.logResult(attempting: "Start email verification", request: request, data: data, response: response, error: error)
                if let _ = error { onFailure(email, EmailSubmissionError.client) ; return }
                let statusCode = (response as! HTTPURLResponse).statusCode
                let submissionError = EmailSubmissionError.emailSubmissionError(from: statusCode)
                guard submissionError == nil else {onFailure(email, submissionError!) ;  return }
                onSuccess(email)
            }
        }
        task?.resume()
    }
    
    func logResult(attempting: String, request: URLRequest, data: Data?, response: URLResponse?, error: Error?) {
        let httpResponse = response as? HTTPURLResponse
        if let error = error {
            logger?.logDataTaskFailure(attempting: attempting, error: error, request: request, response: httpResponse, responseData: data)
            return
        }
        if data == nil {
            let wexError = WEXErrorsFactory.networkErrorFrom(response: httpResponse!, responseData: data, attempting: attempting)!
            logger?.logDataTaskFailure(attempting: attempting, error: wexError, request: request, response: httpResponse, responseData: data)
            return
        }
        logger?.logDataTaskSuccess(request: request, response: httpResponse!, responseData: data!)
    }
    
    public func verifyWithCode(email: String, code: String, onSuccess: @escaping  ( _ email:String) -> Void, onFailure: @escaping (_ email:String, _ error:CodeValidationError) -> Void) {
        guard email == self.email else { onFailure(email, CodeValidationError.emailNotTheSame) ; return }
        let payload = VerifyPayload(username: email, password: code)
        let payloadData = try! JSONEncoder().encode(payload)
        let request = prepareRequest(urlString: verifyUrlString, method: "POST", bodyData: payloadData)
        task?.cancel()
        task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async { [ weak self] in
                self?.logResult(attempting: "Verify with code", request: request, data: data, response: response, error: error)
                if let _ = error { onFailure(email, CodeValidationError.client) ; return }
                let statusCode = (response as! HTTPURLResponse).statusCode
                let verificationError = CodeValidationError.codeValidationError(from: statusCode)
                guard verificationError == nil else { onFailure(email, verificationError!) ; return }
                onSuccess(email)
            }
        }
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
    
    
    func makeStartPayload(email: String) -> StartPayload {
        return StartPayload(email: email, client_id: startClientId)
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

struct Telemetery : Encodable {
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
