//
//  FindAddressService.swift
//  WorkfinderCoordinators
//
//  Created by Keith Staines on 18/03/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import Foundation
import WorkfinderCommon

public protocol ValidatePostcodeServiceProtocol {
    func validatePostcode(_ postcode: String, completion: @escaping (Result<Bool,WorkfinderError>) -> Void)
}

public class ValidatePostcodeService: ValidatePostcodeServiceProtocol {
        
    public func validatePostcode(_ postcode: String, completion: @escaping (Result<Bool,WorkfinderError>) -> Void) {
        let attempting = "validatePostcode"
        let request = buildRequest(postcode: postcode)
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(WorkfinderError(errorType: .error(error! as NSError), attempting: attempting)))
                return
            }
            let error: WorkfinderError?
            switch response.statusCode {
            case 200: // known postcode
                error = nil
            case 400: // not valid postcode
                error = WorkfinderError.init(title: "Postcode not valid", description: "Please check your postcode")
            case 404: // no addresses found at postcode
                error = WorkfinderError.init(title: "No addresses found", description: "")
            default:
                error = WorkfinderError.init(title: "Unable to validate postcode", description: "An unexpected error occurred")
            }
            
            switch error {
            case .none:
                completion(.success(true))
            case .some(let error):
                completion(.failure(error))
            }

        }
        task.resume()
    }
    
    var session: URLSession { ValidatePostcodeService.session }
    
    public init() {}
    
    func buildRequest(postcode: String) -> URLRequest {
        let postcode = postcode.trimmingCharacters(in: .whitespacesAndNewlines).addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
        let apiKey = "3SzEU4S6Ck2o7OEsyi9uyA27429"
        let url = URL(string:"https://api.getAddress.io/find/\(postcode)?api-key=\(apiKey)")!
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30.0)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    
    static var session: URLSession { URLSession(configuration: config) }
    
    static var config: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        return config
    }
}
