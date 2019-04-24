//
//  F4SContentType.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 16/04/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

public enum F4SContentType: String, Codable {
    case about = "about-workfinder"
    case recommendations
    case faq
    case terms
    case voucher
    case consent
    case company
}

public struct F4SContentDescriptor : Codable {
    public var title: String
    public var slug: F4SContentType
    public var url: String?
    
    public init(title: String = "", slug: F4SContentType = .about, url: String? = "") {
        self.title = title
        self.slug = slug
        self.url = url
    }
}
