//
//  Entities.swift
//  f4s-workexperience
//
//  Created by Andreea Rusu on 26/04/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit

struct F4SApplicationContext {
    var user: User?
    var company: Company?
    var placement: Placement?
    var availabilityPeriod: F4SAvailabilityPeriod?
    
    public init(user: User? = nil, company: Company? = nil, placement: Placement? = nil, availabilityPeriod: F4SAvailabilityPeriod? = nil) {
        self.user = user
        self.company = company
        self.placement = placement
        self.availabilityPeriod = availabilityPeriod
    }
}

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
        self.requiresConsent = false
        self.placementUuid = placementUuid
    }
}

public struct Company : Hashable {
    
    public static let defaultLogo = UIImage(named: "DefaultLogo")
    
    public var hashValue: Int {
        return uuid.hashValue ^ latitude.hashValue ^ longitude.hashValue
    }
    
    public static func ==(lhs: Company, rhs: Company) -> Bool {
        if lhs.uuid == rhs.uuid && lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude {
            return true
        }
        return false
    }
    
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
    public var interestIds: Set<Int64> = Set<Int64>()

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
    
    /// Asynchronously obtains the logo for the current instance or the specified default logo if the current instance has no specified logo. This method is intended for direct use by the UI and therefore the completion handler is guarenteed to run on the main queue.
    /// - parameter defaultLogo: The image to use if the company hasn't specified a logo
    /// - parameter completion: To receive the logo (or the specified default image)
    func getLogo(defaultLogo: UIImage?, completion: @escaping (UIImage?) -> () ) {
        if logoUrl.isEmpty { return }
        guard let url = URL(string: logoUrl) as NSURL? else {
            DispatchQueue.main.async {
                completion(defaultLogo)
            }
            return
        }
        ImageService.sharedInstance.getImage(url: url, completed: { succeeded, image in
            DispatchQueue.main.async {
                completion(image ?? defaultLogo)
            }
        })
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

public struct BusinessCompanyInterest : Hashable {
    public static func ==(lhs: BusinessCompanyInterest, rhs: BusinessCompanyInterest) -> Bool {
        if lhs.interestId == rhs.interestId && lhs.companyId == lhs.companyId {
            return true
        }
        return false
    }
    
    public var hashValue: Int {
        return companyId.hashValue ^ interestId.hashValue
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

public struct Interest : Hashable {
    public var hashValue: Int { return uuid.hashValue }
    
    public static func ==(lhs: Interest, rhs: Interest) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    public var id: Int64
    public var uuid: String
    public var name: String

    public init(id: Int64 = 0, uuid: String = "", name: String = "") {
        self.id = id
        self.uuid = uuid
        self.name = name
    }
}

struct TemplateEntity {
    var uuid: String
    var template: String
    var blanks: [TemplateBlank]

    init(uuid: String = "", template: String = "", blank: [TemplateBlank] = []) {
        self.uuid = uuid
        self.template = template
        self.blanks = blank
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
    
    var uuidIsDate: Bool {
        return Date.dateFromRfc3339(string: uuid) == nil ? false : true
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

struct TimelinePlacement {
    var placementUuid: String
    var userUuid: String
    var companyUuid: String
    var threadUuid: String
    var status: PlacementStatus
    var latestMessage: F4SMessage
    var isRead: Bool

    init(placementUuid: String = "", userUuid: String = "", companyUuid: String = "", threadUuid: String = "", status: PlacementStatus = .inProgress, latestMessage: F4SMessage = F4SMessage(), isRead: Bool = true) {
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

struct Shortlist : Hashable {
    var hashValue: Int {
        return companyUuid.hashValue
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
    case recommendation
}
