//
//  Entities.swift
//  f4s-workexperience
//
//  Created by Andreea Rusu on 26/04/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit
import WorkfinderCommon

struct F4SApplicationContext {
    var user: F4SUser?
    var company: Company?
    var placement: F4SPlacement?
    
    public init(user: F4SUser? = nil, company: Company? = nil, placement: F4SPlacement? = nil) {
        self.user = user
        self.company = company
        self.placement = placement
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
    public var isAvailableForSearch: Bool
    public var uuid: String
    public var name: String {
        didSet { self.sortingName = name.stripCompanySuffix().lowercased() }
    }
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

    public init(id: Int64 = 0, created: Date = Date(), modified: Date = Date(), isAvailableForSearch: Bool = true, uuid: String = "", name: String = "", logoUrl: String = "", industry: String = "", latitude: Double = 0, longitude: Double = 0, summary: String = "", employeeCount: Int64 = 0, turnover: Double = 0, turnoverGrowth: Double = 0, rating: Double = 0, ratingCount: Double = 0, sourceId: String = "", hashtag: String = "", companyUrl: String = "") {
        self.id = id
        self.created = created
        self.modified = modified
        self.isAvailableForSearch = isAvailableForSearch
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
        self.sortingName = name.stripCompanySuffix().lowercased()
    }
    
    /// The name after having been stripped of company suffixes (LTD, etc) and lowercased. Intended for use in searching scenarios, this is not a computed property.
    var sortingName: String
    
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
        F4SImageService.sharedInstance.getImage(url: url, completion: { image in
            completion(image ?? defaultLogo)
        })
    }
    
    var placement: F4SPlacement? {
        return PlacementDBOperations.sharedInstance.getPlacementForCompany(companyUuid: uuid)
    }
}

public struct Placement {
    public var companyUuid: String
    public var interestsList: [F4SInterest]
    public var status: PlacementStatus
    public var placementUuid: String

    public init(companyUuid: String = "", interestsList: [F4SInterest] = [], status: PlacementStatus = .inProgress, placementUuid: String = "") {
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

public enum PlacementStatus {
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

enum SocialShare: String {
    case sms
    case email
    case twitter
    case facebook
    case other
}
