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

struct Shortlist : Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(companyUuid)
    }
    
    static func ==(lhs: Shortlist, rhs: Shortlist) -> Bool {
        return lhs.companyUuid == rhs.companyUuid
    }
    
    var companyUuid: String
    var uuid: String
    var date: Date

    init(companyUuid: String = "", uuid: String = "", date: Date = Date()) {
        self.companyUuid = companyUuid
        self.uuid = uuid
        self.date = date
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

enum SocialShare: String {
    case sms
    case email
    case twitter
    case facebook
    case other
}
