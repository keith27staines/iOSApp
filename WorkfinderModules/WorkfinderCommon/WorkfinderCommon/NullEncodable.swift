//
//  NullEncodable.swift
//  WorkfinderCommon
//
//  Created by Keith Staines on 27/05/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import Foundation

@propertyWrapper
public struct NullEncodable<T>: Encodable where T: Encodable {
    
    public var wrappedValue: T?

    public init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch wrappedValue {
        case .some(let value): try container.encode(value)
        case .none: try container.encodeNil()
        }
    }
}
