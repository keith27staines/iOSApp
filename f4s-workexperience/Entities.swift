//
//  Entities.swift
//  f4s-workexperience
//
//  Created by Andreea Rusu on 26/04/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit
import WorkfinderCommon

public struct BusinessCompanyInterest : Hashable {
    public static func ==(lhs: BusinessCompanyInterest, rhs: BusinessCompanyInterest) -> Bool {
        if lhs.interestId == rhs.interestId && lhs.companyId == lhs.companyId {
            return true
        }
        return false
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(companyId)
        hasher.combine(interestId)
    }
    
    public var id: Int64
    public var interestId: Int64
    public var companyId: Int64
    public init(id: Int64 = 0, interestId: Int64 = 0, companyId: Int64 = 0) {
        self.id = id
        self.interestId = interestId
        self.companyId = companyId
    }
}

struct ContentEntity {
    var title: String
    var slug: ContentType
    var url: String?

    init(title: String = "", slug: ContentType = .about, url: String? = "") {
        self.title = title
        self.slug = slug
        self.url = url
    }
}

struct UserStatus {
    var unreadCount: Int
    var unratedPlacements: [String]

    init(unreadCount: Int = 0, unratedPlacements: [String] = []) {
        self.unreadCount = unreadCount
        self.unratedPlacements = unratedPlacements
    }
}



enum ContentType: String {
    case about = "about-workfinder"
    case recommendations
    case faq
    case terms
    case voucher
    case consent
    case company
}

enum TemplateOptionType {
    case multiSelect
    case select
    case date
}

// MARK: - call entities
struct CompanyDatabaseMeta {
    var created: String
    var url: String

    init(created: String = "", url: String = "") {
        self.created = created
        self.url = url
    }
}
