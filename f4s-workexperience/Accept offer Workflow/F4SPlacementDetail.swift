//
//  F4SPlacementDetail.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 19/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

public struct F4SPlacementInviteSectionDetails {
    public var title: String?
    public var icon: UIImage?
    public var lines: [String]?
    public var linkUrl: URL?
    public var isEmail: Bool
    
    public var requiresButtonAction: Bool = false
    
    public init(title: String? = nil, icon: UIImage? = nil, lines: [String]? = nil, linkUrl: URL? = nil, isEmail: Bool = false){
        self.requiresButtonAction = false
        self.title = title
        self.icon = icon
        self.lines = lines
        self.linkUrl = linkUrl
        self.isEmail = isEmail
    }
    public init(title: String? = nil, icon: UIImage? = nil, lines: [String]? = nil, linkUrlString: String? = nil, isEmail: Bool = false){
        self.requiresButtonAction = false
        self.title = title
        self.icon = icon
        self.lines = lines
        self.linkUrl = URL(string: linkUrlString ?? "")
        self.isEmail = isEmail
    }

}

public struct F4SPlacementInviteHeading {
    public init(title: String?) {
        self.title = title
    }
    public var title: String? = nil
}

public struct F4SPlacementInviteSection {
    public init(title: String?) {
        self.heading = F4SPlacementInviteHeading(title: title)
    }
    public var heading: F4SPlacementInviteHeading
    public var inviteDetails: [F4SPlacementInviteSectionDetails] = [F4SPlacementInviteSectionDetails]()
}

public class F4SPlacementInviteModel {

    private var sections: [F4SPlacementInviteSection]
    
    public func numberOfSections() -> Int {
        return sections.count
    }
    
    public func numberOfRows(_ section: Int) -> Int {
        return sections[section].inviteDetails.count
    }
    
    public func inviteDetailsForIndexPath(_ indexPath: IndexPath) -> F4SPlacementInviteSectionDetails {
        return sections[indexPath.section].inviteDetails[indexPath.row]
    }
    
    public func headerForSection(_ section: Int) -> F4SPlacementInviteHeading {
        return sections[section].heading
    }
    
    internal init (context: AcceptOfferContext) {
        let company =  context.company
        let placement = context.placement
        var detail: F4SPlacementInviteSectionDetails
        var lines: [String]
        let dateFormatted = DateFormatter()
        dateFormatted.dateStyle = .short
        
        // Offer Is From section
        var offerIsFromSection = F4SPlacementInviteSection(title: "Offer is from")
        lines = [context.company.name.stripCompanySuffix()]
        detail = F4SPlacementInviteSectionDetails(icon: UIImage(named: "ui-company-icon"), lines: lines, linkUrlString: nil)
        detail.requiresButtonAction = true
        offerIsFromSection.inviteDetails.append(detail)
        
        lines = ["Company LinkedIn profile"]
        detail = F4SPlacementInviteSectionDetails(icon: UIImage(named: "ui-linkedin-icon"), lines: lines, linkUrlString: company.companyUrl)
        offerIsFromSection.inviteDetails.append(detail)
        
        // Role offered section
        var roleOfferedSection = F4SPlacementInviteSection(title: "Role offered")
        lines = [context.role?.name ?? "not specified"]
        detail = F4SPlacementInviteSectionDetails(icon: UIImage(named: "ui-rolearrow-icon"), lines: lines, linkUrl: nil)
        roleOfferedSection.inviteDetails.append(detail)
        
        let duration = placement.duration
        
        let formattedStartDateString = F4SDateHelper.unformattedAcceptDateStringToFormattedString(unformattedString: duration?.start_date)
        lines = [] //[formattedStartDateString]
        detail = F4SPlacementInviteSectionDetails(title: "Start date: \(formattedStartDateString)\n ", icon: UIImage(named: "ui-calendar-icon"), lines: lines, linkUrl: nil)
        roleOfferedSection.inviteDetails.append(detail)
        
        let formattedEndDateString = F4SDateHelper.unformattedAcceptDateStringToFormattedString(unformattedString: duration?.end_date)
        lines = [] //[formattedEndDateString]
        detail = F4SPlacementInviteSectionDetails(title: "End date: \(formattedEndDateString)", icon: UIImage(named: "ui-calendar-icon"), lines: lines, linkUrl: nil)
        roleOfferedSection.inviteDetails.append(detail)
        
        lines = F4SPlacementInviteModel.totalHoursLines(placement: placement)
        detail = F4SPlacementInviteSectionDetails(title: "Total hours", icon: UIImage(named: "ui-clockface-icon"), lines: lines, linkUrl: nil)
        roleOfferedSection.inviteDetails.append(detail)
        
        // Person responsible section
        var personResponsibleSection = F4SPlacementInviteSection(title: "Person responsible")
        if let personResponsible = context.placement.personResponsible {
            lines = [personResponsible.name ?? ""]
            detail = F4SPlacementInviteSectionDetails(icon: UIImage(named: "ui-contact-icon"), lines: lines, linkUrlString: nil)
            personResponsibleSection.inviteDetails.append(detail)
            lines = ["linkedin"]
            detail = F4SPlacementInviteSectionDetails(icon: UIImage(named: "ui-linkedin-icon"), lines: lines, linkUrlString: personResponsible.linkedinProfile)
            personResponsibleSection.inviteDetails.append(detail)
            if let email = personResponsible.email {
                lines = [email]
                detail = F4SPlacementInviteSectionDetails(icon: UIImage(named: "ui-email-icon"), lines: lines, linkUrlString: nil, isEmail: true)
                personResponsibleSection.inviteDetails.append(detail)
            }
        }
        
        // Location of placement section
        var locationSection = F4SPlacementInviteSection(title: "Location of placement")
        if let location = context.placement.location {
            lines = F4SPlacementInviteModel.addressLines(location: location)
            detail = F4SPlacementInviteSectionDetails(icon: UIImage(named: "ui-icon-location"), lines: lines, linkUrlString: nil)
            locationSection.inviteDetails.append(detail)
            lines = [location.phoneNumber ?? ""]
            detail = F4SPlacementInviteSectionDetails(icon: UIImage(named: "ui-phone-icon"), lines: lines, linkUrlString: nil)
            locationSection.inviteDetails.append(detail)
            if let website = location.website, website.isEmpty == false {
                lines = ["location website"]
                detail = F4SPlacementInviteSectionDetails(icon: UIImage(named: "ui-www-icon"), lines: lines, linkUrlString: website)
            }
            locationSection.inviteDetails.append(detail)
        }

        // Add all the sections we have built
        sections = [F4SPlacementInviteSection]()
        self.sections = [offerIsFromSection, roleOfferedSection, personResponsibleSection, locationSection]
    }
    
    internal static func addressLines(location: F4SLocationJson?) -> [String] {
        guard let address = location?.address else { return [] }
        var result = [String]()
        if let building = address.building, building.isEmpty == false { result.append(building) }
        if let street = address.street, street.isEmpty == false { result.append(street) }
        if let address3 = address.address3, address3.isEmpty == false { result.append(address3) }
        if let town = address.town, town.isEmpty == false { result.append(town) }
        if let locality = address.locality, locality.isEmpty == false { result.append(locality) }
        if let county = address.county, county.isEmpty == false { result.append(county)}
        if let postcode = address.postcode, postcode.isEmpty == false { result.append(postcode) }
        return result
    }
    
    internal static func totalHoursLines(placement: F4STimelinePlacement) -> [String] {
        var result = [""] // value will be supplied later
        guard let duration = placement.duration else { return result }
        var fullTime = true
        if let dayTimeInfo = duration.day_time_info {
            for dayInfo in dayTimeInfo {
                guard let day = F4SDayOfWeek(nameOfDay: dayInfo.day) else {
                    continue
                }
                result.append(day.mediumSymbol + " " + dayInfo.time)
                if dayInfo.time.lowercased() != "all" {
                    fullTime = false
                }
            }
        }

        result[0] = fullTime == true ? "Full time:" : "Part time:"
        result.append("AM hours: 0900 - 1200")
        result.append("PM hours: 1200 - 1600")
        return result
    }
    
    public init() {
        var detail: F4SPlacementInviteSectionDetails
        var lines: [String]
        
        // Offer Is From section
        var offerIsFrom = F4SPlacementInviteSection(title: "Offer is from")
        lines = ["Company"]
        detail = F4SPlacementInviteSectionDetails(icon: UIImage(named: "ui-company-icon"), lines: lines, linkUrlString: "google.com")
        offerIsFrom.inviteDetails.append(detail)
        lines = ["Company LinkedIn profile"]
        detail = F4SPlacementInviteSectionDetails(icon: UIImage(named: "ui-linkedin-icon"), lines: lines, linkUrlString: "linkedin.com")
        offerIsFrom.inviteDetails.append(detail)
        
        // Role offered section
        var roleOffered = F4SPlacementInviteSection(title: "Role offered")
        lines = ["Engineering role"]
        detail = F4SPlacementInviteSectionDetails(icon: UIImage(named: "ui-rolearrow-icon"), lines: lines, linkUrl: nil)
        roleOffered.inviteDetails.append(detail)
        lines = ["18 Jan 18"]
        detail = F4SPlacementInviteSectionDetails(title: "Start date", icon: UIImage(named: "ui-calendar-icon"), lines: lines, linkUrl: nil)
        roleOffered.inviteDetails.append(detail)
        lines = ["21 Jan 18"]
        detail = F4SPlacementInviteSectionDetails(title: "End date", icon: UIImage(named: "ui-calendar-icon"), lines: lines, linkUrl: nil)
        roleOffered.inviteDetails.append(detail)
        lines = ["Part time", "Tuesday AM", "Wednesday PM", "AM hours: 0900 - 1200", "PM hours: 1200 - 1600"]
        detail = F4SPlacementInviteSectionDetails(title: "Total hours", icon: UIImage(named: "ui-clockface-icon"), lines: lines, linkUrl: nil)
        roleOffered.inviteDetails.append(detail)
        lines = ["24 (TBC?)"]
        detail = F4SPlacementInviteSectionDetails(title: "Days and hours", icon: UIImage(named: "ui-clockface-icon"), lines: lines, linkUrl: nil)
        roleOffered.inviteDetails.append(detail)
        
        // Person responsible section
        var personResponsible = F4SPlacementInviteSection(title: "Person responsible")
        lines = ["John Snow"]
        detail = F4SPlacementInviteSectionDetails(icon: UIImage(named: "ui-contact-icon"), lines: lines, linkUrlString: nil)
        personResponsible.inviteDetails.append(detail)
        lines = ["linkedin"]
        detail = F4SPlacementInviteSectionDetails(icon: UIImage(named: "ui-linkedin-icon"), lines: lines, linkUrlString: "linkedin.com")
        personResponsible.inviteDetails.append(detail)
        lines = ["johnsnow@winterfell.com"]
        detail = F4SPlacementInviteSectionDetails(icon: UIImage(named: "ui-email-icon"), lines: lines, linkUrlString: nil, isEmail: true)
        personResponsible.inviteDetails.append(detail)
        
        
        // Location of placement section
        var location = F4SPlacementInviteSection(title: "Location of placement")
        lines = ["Eastwatch by the Sea", "The Wall", "The North", "ST4 R4K"]
        detail = F4SPlacementInviteSectionDetails(icon: UIImage(named: "ui-icon-location"), lines: lines, linkUrlString: nil)
        location.inviteDetails.append(detail)
        lines = ["020 6574 758"]
        detail = F4SPlacementInviteSectionDetails(icon: UIImage(named: "ui-phone-icon"), lines: lines, linkUrlString: nil)
        location.inviteDetails.append(detail)
        lines = ["google.com"]
        detail = F4SPlacementInviteSectionDetails(icon: UIImage(named: "ui-www-icon"), lines: lines, linkUrlString: "google.com")
        location.inviteDetails.append(detail)
        
        // Add all the sections we have built
        sections = [F4SPlacementInviteSection]()
        self.sections = [offerIsFrom, roleOffered, personResponsible, location]
        
    }
    
}















