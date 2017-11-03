//
//  Partner.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 26/10/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import Foundation

public struct Partner {
    /// A uuid that is meaningful to the Workfinder server
    var uuid: F4SUUID
    /// An index used for sorting partners when displayed in a list
    var sortingIndex: Int
    /// A name describing the partner
    var name: String
    /// An acronym describing the partner
    var acronym: String?
    /// A longer description of the partner
    var description: String?
    /// The name of an image that can be used to represent the partner in an icon
    var imageName: String?
    /// imageURL
    var imageUrlString: String?
    /// An image that can be used to represent the partner in an icon
    var image: UIImage? {
        guard let imageName = self.imageName else { return nil }
        return UIImage(named: imageName)
    }
    public init() {
        self.init(uuid: "", name: "")
    }
    
    public init(uuid: F4SUUID,
                sortingIndex: Int = 0,
                acronym: String? = nil,
                name: String,
                description: String? = nil,
                imageName: String? = nil) {
        self.uuid = uuid
        self.sortingIndex = sortingIndex
        self.acronym = acronym
        self.name = name
        self.description = description
        self.imageName = imageName
    }
    
    /// A placeholder partner used while waiting for the user to
    static var partnerProvidedLater: Partner {
        let name = NSLocalizedString("I will provide this later", comment: "Inform the user that they can skip providing this information now, but it might be requested again later")
        var p = Partner(uuid: SystemF4SUUID.willProvideLater.rawValue, name: name)
        p.sortingIndex = Int.max
        return p
    }
}
