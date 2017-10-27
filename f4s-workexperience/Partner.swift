//
//  Partner.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 26/10/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import Foundation

public struct Partner {
    var uuid: PartnerUUID
    var name: String
    var acronym: String?
    var description: String?
    var imageName: String?
    var image: UIImage? {
        guard let imageName = self.imageName else { return nil }
        return UIImage(named: imageName)
    }
    
    public init(uuid: PartnerUUID,
                acronym: String? = nil,
                name: String,
                description: String? = nil,
                imageName: String? = nil) {
        self.uuid = uuid
        self.acronym = acronym
        self.name = name
        self.description = description
        self.imageName = imageName
    }
}
