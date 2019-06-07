//
//  F4SJsonDecoding.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 08/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

/// Extensions to aid the transformation of F4SNetworkResults into F4SNetowrkResults
public extension JSONDecoder {
    /// Attempts to convert a F4SNetworkDataResult into an F4SNetworkResult
    /// If `dataResult` contains an error then the error is wrapped inside the F4SNetworkResult returned by the completion handler
    /// If`dataResult` contains data, the data is decoded into the specified type and wrapped inside the F4SNetworkResult
    ///
    /// - parameter dataResult: The network result to be decoded and converted into a network result
    /// - parameter intoType: The type into which the data is to be decoded
    /// - parameter attempting: A string describing the purpose of the call
    /// - parameter completion: Returns the result
    func decode<A:Decodable>(dataResult: F4SNetworkDataResult, intoType: A.Type, attempting: String, completion: (F4SNetworkResult<A>) -> ()) {
        switch dataResult {
        case .error(let error):
            completion(F4SNetworkResult.error(error))
        case .success(let data):
            self.decode(data: data, intoType: intoType, attempting: attempting, completion: completion)
        }
    }
    
    /// Attempts to convert data into an F4SNetworkResult
    ///
    /// - parameter data: The data be decoded and converted into a network result
    /// - parameter intoType: The type into which the data is to be decoded
    /// - parameter attempting: A string describing the purpose of the call
    /// - parameter completion: Returns the result
    func decode<A:Decodable>(data: Data?, intoType: A.Type, attempting: String, completion: (F4SNetworkResult<A>) -> ()) {
        guard let data = data else {
            let noDataError = F4SNetworkDataErrorType.noData.error(attempting: attempting)
            completion(F4SNetworkResult.error(noDataError))
            return
        }
        do {
            let decoded = try self.decode(intoType, from: data)
            completion(F4SNetworkResult.success(decoded))
        } catch {
            print(error)
            let deserializationError = F4SNetworkDataErrorType.deserialization(data).error(attempting: attempting)
            completion(F4SNetworkResult.error(deserializationError))
        }
    }
}
