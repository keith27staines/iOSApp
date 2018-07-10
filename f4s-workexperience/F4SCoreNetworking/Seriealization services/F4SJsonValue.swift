//
//  F4SJsonValue.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 06/07/2018.
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

extension F4SJSONValue: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let string): try container.encode(string)
        case .int(let int): try container.encode(int)
        case .double(let double): try container.encode(double)
        case .bool(let bool): try container.encode(bool)
        case .object(let object): try container.encode(object)
        case .array(let array): try container.encode(array)
        }
    }
}

extension F4SJSONValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension F4SJSONValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .int(value)
    }
}

extension F4SJSONValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .double(value)
    }
}

extension F4SJSONValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension F4SJSONValue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: F4SJSONValue...) {
        self = .array(elements)
    }
}

extension F4SJSONValue: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, F4SJSONValue)...) {
        self = .object([String: F4SJSONValue](uniqueKeysWithValues: elements))
    }
}
