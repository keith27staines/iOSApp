//
//  CompanyWorkplaceListProvider.swift
//  CompanyList
//
//  Created by Keith Dev on 22/03/2020.
//  Copyright © 2020 Founders4Schools. All rights reserved.
//

import Foundation

public typealias F4SUUID = String

//http://workfinder-develop.eu-west-2.elasticbeanstalk.com/v3/companies/?locations__uuid__in=4764e857-51ac-4b82-a97d-6a502c2d4dad

public enum NetworkError: Error {
    case clientError(Error)
    case httpError(HTTPURLResponse)
    case responseBodyEmpty(HTTPURLResponse)
}

public protocol CompanyWorkplaceListProviderProtocol {
    func fetchCompanyWorkplaces(
        locationUuids: [F4SUUID],
        completion: @escaping ((Result<Data,Error>) -> Void))
}

extension CompanyWorkplaceListProvider: CompanyWorkplaceListProviderProtocol {
    
    public func fetchCompanyWorkplaces(
        locationUuids: [F4SUUID],
        completion: @escaping ((Result<Data,Error>) -> Void)) {
        
        self.completion = completion
        buildTask(locationUuids: locationUuids)
        .resume()
    }
}

public class CompanyWorkplaceListProvider {
    let endpoint = "http://workfinder-develop.eu-west-2.elasticbeanstalk.com/v3/companies"
    var session: URLSession { return URLSession(configuration: URLSessionConfiguration.default) }
    
    var task: URLSessionDataTask?
    
    var completion: ((Result<Data,Error>) -> Void)?
    
    func taskCompletionHandler(data: Data?, response: URLResponse?, error: Error?) {
        guard let response = response as? HTTPURLResponse else {
            if let error = error {
                let result = Result<Data, Error>.failure(error)
                completion?(result)
                return
            }
            return
        }
        let code = response.statusCode
        switch code {
        case 200..<300:
            guard let  data = data else {
                let httpError = NetworkError.responseBodyEmpty(response)
                let result = Result<Data, Error>.failure(httpError)
                completion?(result)
                return
            }
            completion?(Result<Data,Error>.success(data))
        default:
            let httpError = NetworkError.httpError(response)
            let result = Result<Data, Error>.failure(httpError)
            completion?(result)
            return
        }
    }
    
    func makeURL(locationUuids: [F4SUUID]) -> URL {
        var components = URLComponents(string: endpoint)!
        let uuidString = makeCommaSeparatedList(uuids: locationUuids)
        let queryItem = URLQueryItem(name: "locations__uuid__in", value: uuidString)
        components.queryItems = [queryItem]
        return components.url!
    }
    
    func makeURLRequest(locationUuids: [F4SUUID]) -> URLRequest {
        let url = makeURL(locationUuids: locationUuids)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
    
    func buildTask(locationUuids: [F4SUUID]) -> URLSessionDataTask {
        task?.cancel()
        let request = makeURLRequest(locationUuids: locationUuids)
        task = session.dataTask(with: request, completionHandler: taskCompletionHandler)
        return task!
    }
    
    func makeCommaSeparatedList(uuids: [F4SUUID]) -> String {
        var list: String = ""
        for uuid in uuids {
            list.append(uuid)
            list.append(",")
        }
        list.removeLast()
        return list
    }
    
}
