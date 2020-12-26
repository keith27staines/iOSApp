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

public class MockUserRepository: UserRepositoryProtocol {
    
    var accessToken: String?
    var user: User?
    var candidate: Candidate?
    
    public var isCandidateLoggedIn: Bool = false
    
    public func saveUser(_ user: User) {
        self.user = user
    }
    
    public func saveCandidate(_ candidate: Candidate) {
        self.candidate = candidate
    }
    
    public func loadUser() -> User {
        return user ?? User()
    }
    

    public init(user: User? = nil, candidate: Candidate? = nil) {
        self.user = user
        self.candidate = candidate
    }
    
    public func loadCandidate() -> Candidate {
        return candidate ?? Candidate()
    }
    
    public func loadAccessToken() -> String? {
        return accessToken
    }
    
    public func saveAccessToken(_ token: String) {
        self.accessToken = token
    }
}
