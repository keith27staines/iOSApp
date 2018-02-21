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
    // primary key
    public let companyId: Int64
    // Position of an office or outlet of the company
    public let position: CLLocationCoordinate2D
    /// true if the pin should be shown on the map, otherwise false
    public var shouldShowView: Bool = true
    /// The uuid of the company
    public let companyUuid: F4SUUID
    /// Interests of the company
    lazy public var interestIds: F4SInterestIdSet = {
        let interestIdList = DatabaseOperations.sharedInstance.interestIdsFor(companyId: self.companyId)
        return F4SInterestIdSet(interestIdList)
    }()
    /// True if the user has favourited the company
    public var isFavourite: Bool
    
    /// Returns a view for use as the pin on the map
    @objc func customMarkerView() -> UIView {
        let imageName = isFavourite ? "markerFavouriteIcon" : "markerIcon"
        let image = UIImage(named: imageName)
        let view = UIImageView(image: image)
        return view
    }
    
    // MARK:- Hashable conformance
    override public var hashValue: Int {
        return position.latitude.hashValue ^ position.longitude.hashValue ^ companyUuid.hashValue
    }
    
    public static func ==(lhs: F4SCompanyPin, rhs: F4SCompanyPin) -> Bool {
        return
            lhs.position.latitude == rhs.position.latitude &&
                lhs.position.longitude == rhs.position.longitude  &&
                lhs.companyUuid == rhs.companyUuid
    }
    
    /// adds the specified interests if they aren't already there
    public func addInterests(_ interests: F4SInterestIdSet) {
        self.interestIds.formUnion(interests)
    }
    
    /// Initialises a new instance from a Company
    public init(company: Company) {
        self.position = CLLocationCoordinate2D(latitude: company.latitude, longitude: company.longitude)
        self.companyId = company.id
        self.companyUuid = company.uuid
        self.isFavourite = false
        self.shouldShowView = true
    }
}
