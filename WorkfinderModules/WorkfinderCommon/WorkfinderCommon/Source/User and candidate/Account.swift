//
//  Account.swift
//  WorkfinderCommon
//
//  Created by Keith Staines on 09/04/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

public struct Account: Codable, Equatable {
    public var user: User
    public var candidate: Candidate
    
    public init(user: User, candidate: Candidate) {
        self.user = user
        self.candidate = candidate
    }
}
