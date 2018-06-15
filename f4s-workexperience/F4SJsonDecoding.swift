//
//  F4SJsonDecoding.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 08/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

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
