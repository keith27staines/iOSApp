//
//  F4SJsonDecoding.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 08/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public extension JSONDecoder {
    
    public func decode<A:Decodable>(dataResult: F4SNetworkDataResult, intoType: A.Type, attempting: String, completion: (F4SNetworkResult<A>) -> ()) {
        switch dataResult {
        case .error(let error):
            completion(F4SNetworkResult.error(error))
        case .success(let data):
            self.decode(data: data, intoType: intoType, attempting: attempting, completion: completion)
        }
    }
    
    public func decode<A:Decodable>(data: Data?, intoType: A.Type, attempting: String, completion: (F4SNetworkResult<A>) -> ()) {
        guard let data = data else {
            let noDataError = F4SNetworkDataErrorType.noData.error(attempting: attempting)
            completion(F4SNetworkResult.error(noDataError))
            return
        }
        do {
            let decoded = try self.decode(intoType, from: data)
            completion(F4SNetworkResult.success(decoded))
        } catch {
            let deserializationError = F4SNetworkDataErrorType.deserialization(data).error(attempting: attempting)
            completion(F4SNetworkResult.error(deserializationError))
        }
    }
}

public enum F4SJSONValue: Decodable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case object([String: F4SJSONValue])
    case array([F4SJSONValue])
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode([String: F4SJSONValue].self) {
            self = .object(value)
        } else if let value = try? container.decode([F4SJSONValue].self) {
            self = .array(value)
        } else {
            throw DecodingError.typeMismatch(F4SJSONValue.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Not a JSON"))
        }
    }
}
