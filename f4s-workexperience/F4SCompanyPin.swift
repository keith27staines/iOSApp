//
//  F4SCompanyPin.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 04/10/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import Foundation

// MARK:-
public class F4SCompanyPin : NSObject, GMUClusterItem {
    public let position: CLLocationCoordinate2D
    public var shouldShowView: Bool = true
    public let uuid: F4SUUID
    public var interestIds: F4SInterestIdsSet
    public var isFavourite: Bool
    
    // MARK:- Hashable conformance
    override public var hashValue: Int {
        return position.latitude.hashValue ^ position.longitude.hashValue ^ uuid.hashValue
    }
    public static func ==(lhs: F4SCompanyPin, rhs: F4SCompanyPin) -> Bool {
        return
            lhs.position.latitude == rhs.position.latitude &&
                lhs.position.longitude == rhs.position.longitude  &&
                lhs.uuid == rhs.uuid
    }
    
    /// adds the specified interests if they aren't already there
    public func addInterests(_ interests: F4SInterestIdsSet) {
        self.interestIds.formUnion(interests)
    }
    
    /// Initialize a new instance
    ///
    /// - parameter position: The latitude and longitude of the pin
    /// - parameter uuid: The id of the company the pin represents
    /// - parameter isFavourite: Indicates whether the company has been favourited
    /// - parameter interestIds: The ids of the interests of the company
    /// - parameter shouldShowView: True if the pin is to be shown
    public init(
        position: CLLocationCoordinate2D,
        uuid: F4SUUID,
        isFavourite: Bool = false,
        interestIds: F4SInterestIdsSet = F4SInterestIdsSet(),
        shouldShowView: Bool = true) {
        self.position = position
        self.uuid = uuid
        self.isFavourite = isFavourite
        self.interestIds = interestIds
        self.shouldShowView = true
    }
    
    /// Initialises a new instance from a Company
    public init(company: Company) {
        self.position = CLLocationCoordinate2D(latitude: company.latitude, longitude: company.longitude)
        self.uuid = company.uuid
        self.isFavourite = false
        self.interestIds = F4SInterestIdsSet()
        self.shouldShowView = true
    }
}
