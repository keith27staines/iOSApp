//
//  WEXPerson.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 15/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

public struct WEXPersonJson : Codable {
    public var name: String?
    public var linkedinProfile: String?
    public var email: String?
}

extension WEXPersonJson {
    private enum CodingKeys : String, CodingKey {
        case name
        case linkedinProfile = "linkedin_profile"
        case email
    }
}
