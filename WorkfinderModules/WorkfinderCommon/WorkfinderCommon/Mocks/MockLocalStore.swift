//
//  MockLocalStore.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 31/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

public class MockLocalStore : LocalStorageProtocol {
    
    public var store: [LocalStore.Key: Any]
    
    public init() {
        store = [:]
    }
    
    public func value(key: LocalStore.Key) -> Any? {
        let value = store[key]
        return value
    }
    
    public func setValue(_ value: Any?, for key: LocalStore.Key) {
        store[key] = value
    }
}

public class MockUserRepository: F4SUserRepositoryProtocol {
    var user: F4SUser
    public init(user: F4SUser) {
        self.user = user
    }
    
    public func save(user: F4SUser) {
        self.user = user
    }
    
    public func load() -> F4SUser {
        return user
    }
}
