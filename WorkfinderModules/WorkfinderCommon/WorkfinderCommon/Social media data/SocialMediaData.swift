//
//  SocialMediaData.swift
//  WorkfinderCommon
//
//  Created by Keith on 30/06/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import Foundation

public struct SocialConnection: Codable {
    public var id: Int?
    public var provider: String?
}

public struct LinkedinConnectionData: Codable {
    
    public var id: Int?
    public var provider: String?
    public var extra_data: LinkedinData?
}

public struct LinkedinData: Codable {
    
}
