//
//  Entities.swift
//  f4s-workexperience
//
//  Created by Andreea Rusu on 26/04/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit

struct User {
    var email: String
    var firstName: String
    var lastName: String
    var consenterEmail: String
    var dateOfBirth: String
    var requiresConsent: Bool
    var placementUuid: String

    init(email: String = "", firstName: String = "", lastName: String = "", consenterEmail: String = "", dateOfBirth: String = "", requiresConsent: Bool = false, placementUuid: String = "") {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.consenterEmail = consenterEmail
        self.dateOfBirth = dateOfBirth
        self.requiresConsent = requiresConsent
        self.placementUuid = placementUuid
    }
}

public struct Company {
    public var id: Int64
    public var created: Date
    public var modified: Date
    public var isRemoved: Bool
    public var uuid: String
    public var name: String
    public var logoUrl: String
    public var industry: String
    public var latitude: Double
    public var longitude: Double
    public var summary: String
    public var employeeCount: Int64
    public var turnover: Double
    public var turnoverGrowth: Double
    public var rating: Double
    public var ratingCount: Double
    public var sourceId: String
    public var hashtag: String
    public var companyUrl: String
    public var interestIds: Set<UInt64> = Set<UInt64>()

    public init(id: Int64 = 0, created: Date = Date(), modified: Date = Date(), isRemoved: Bool = false, uuid: String = "", name: String = "", logoUrl: String = "", industry: String = "", latitude: Double = 0, longitude: Double = 0, summary: String = "", employeeCount: Int64 = 0, turnover: Double = 0, turnoverGrowth: Double = 0, rating: Double = 0, ratingCount: Double = 0, sourceId: String = "", hashtag: String = "", companyUrl: String = "") {
        self.id = id
        self.created = created
        self.modified = modified
        self.isRemoved = isRemoved
        self.uuid = uuid
        self.name = name
        self.logoUrl = logoUrl
        self.industry = industry
        self.latitude = latitude
        self.longitude = longitude
        self.summary = summary
        self.employeeCount = employeeCount
        self.turnover = turnover
        self.turnoverGrowth = turnoverGrowth
        self.rating = rating
        self.ratingCount = ratingCount
        self.sourceId = sourceId
        self.hashtag = hashtag
        self.companyUrl = companyUrl
    }
}

struct Placement {
    var companyUuid: String
    var interestsList: [Interest]
    var status: PlacementStatus
    var placementUuid: String

    init(companyUuid: String = "", interestsList: [Interest] = [], status: PlacementStatus = .inProgress, placementUuid: String = "") {
        self.companyUuid = companyUuid
        self.interestsList = interestsList
        self.status = status
        self.placementUuid = placementUuid
    }
}

public struct Interest {
    public var id: Int64
    public var uuid: String
    public var name: String
    public var interestCount: Int64

    public init(id: Int64 = 0, uuid: String = "", name: String = "", interestCount: Int64 = 0) {
        self.id = id
        self.uuid = uuid
        self.name = name
        self.interestCount = interestCount
    }
}

struct TemplateEntity {
    var uuid: String
    var template: String
    var blank: [TemplateBlank]

    init(uuid: String = "", template: String = "", blank: [TemplateBlank] = []) {
        self.uuid = uuid
        self.template = template
        self.blank = blank
    }
}

struct TemplateBlank {
    var name: String
    var placeholder: String
    var optionType: TemplateOptionType
    var maxChoice: Int
    var choices: [Choice]
    var initial: String

    init(name: String = "", placeholder: String = "", optionType: TemplateOptionType = .select, maxChoice: Int = 0, choices: [Choice] = [], initial: String = "") {
        self.name = name
        self.placeholder = placeholder
        self.optionType = optionType
        self.maxChoice = maxChoice
        self.choices = choices
        self.initial = initial
    }
}

struct Choice {
    var uuid: String
    var value: String

    init(uuid: String = "", value: String = "") {
        self.uuid = uuid
        self.value = value
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

struct Message {
    var uuid: String
    var dateTime: Date
    var relativeDateTime: String
    var content: String
    var sender: String

    init(uuid: String = "", dateTime: Date = Date(), relativeDateTime: String = "", content: String = "", sender: String = "") {
        self.uuid = uuid
        self.dateTime = dateTime
        self.relativeDateTime = relativeDateTime
        self.content = content
        self.sender = sender
    }
}

struct MessageOption {
    var uuid: String
    var value: String

    init(uuid: String = "", value: String = "") {
        self.uuid = uuid
        self.value = value
    }
}

struct TimelinePlacement {
    var placementUuid: String
    var userUuid: String
    var companyUuid: String
    var threadUuid: String
    var status: PlacementStatus
    var latestMessage: Message
    var isRead: Bool

    init(placementUuid: String = "", userUuid: String = "", companyUuid: String = "", threadUuid: String = "", status: PlacementStatus = .inProgress, latestMessage: Message = Message(), isRead: Bool = true) {
        self.placementUuid = placementUuid
        self.companyUuid = companyUuid
        self.userUuid = userUuid
        self.threadUuid = threadUuid
        self.status = status
        self.latestMessage = latestMessage
        self.isRead = isRead
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

struct Shortlist {
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

enum PlacementStatus {
    case inProgress
    case applied
    case accepted
    case rejected
    case confirmed
    case completed
    case draft
    case noAge
    case noVoucher
    case noParentalConsent
    case unsuccessful
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

enum ChooseAttributes: String {
    case PersonalAttributes = "attributes"
    case JobRole = "job_role"
    case EmploymentSkills = "skills"
    case StartDate = "start_date"
    case EndDate = "end_date"
}

enum SocialShare: String {
    case sms
    case email
    case twitter
    case facebook
    case other
}

enum NotificationType: String {
    case message
    case rating
}
