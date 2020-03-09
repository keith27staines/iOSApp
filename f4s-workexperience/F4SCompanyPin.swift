//
//  F4SCompanyPin.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 04/10/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

// MARK:-
public class F4SCompanyPin : NSObject, GMUClusterItem {

    // Position of an office or outlet of the company
    public let position: CLLocationCoordinate2D
    /// true if the pin should be shown on the map, otherwise false
    public var shouldShowView: Bool = true
    /// The uuid of the company
    public let companyUuid: F4SUUID
    /// Interests of the company
    public var interestUuids = F4SUUIDSet()
    
    /// Returns a view for use as the pin on the map
    @objc func customMarkerView() -> UIView {
        let imageName = "markerIcon"
        let image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        let view = UIImageView(image: image)
        view.tintColor = tintColor
        return view
    }
    
    public static func ==(lhs: F4SCompanyPin, rhs: F4SCompanyPin) -> Bool {
        return
            lhs.position.latitude == rhs.position.latitude &&
                lhs.position.longitude == rhs.position.longitude  &&
                lhs.companyUuid == rhs.companyUuid
    }
    
    var tintColor: UIColor
    
    /// Initialises a new instance from a Pin
    public init(pin: PinJson, tintColor: UIColor) {
        self.position = CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.lon)
        self.tintColor = tintColor
        self.companyUuid = pin.companyUuid
        self.shouldShowView = true
    }
}
