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
public class F4SWorkplacePin : NSObject, GMUClusterItem {

    // Position of the pin
    public let position: CLLocationCoordinate2D
    /// true if the pin should be shown on the map, otherwise false
    public var shouldShowView: Bool = true
    /// The uuid of the workplace
    public let workplaceUuid: F4SUUID
    /// Interests of the company having this workplace
    public var interestUuids = F4SUUIDSet()
    
    /// Returns a view for use as the pin on the map
    @objc func customMarkerView() -> UIView {
        let imageName = "markerIcon"
        let image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        let view = UIImageView(image: image)
        view.tintColor = tintColor
        return view
    }
    
    public static func ==(lhs: F4SWorkplacePin, rhs: F4SWorkplacePin) -> Bool {
        return
            lhs.position.latitude == rhs.position.latitude &&
                lhs.position.longitude == rhs.position.longitude  &&
                lhs.workplaceUuid == rhs.workplaceUuid
    }
    
    var tintColor: UIColor
    
    /// Initialises a new instance from a Pin
    public init(pin: PinJson, tintColor: UIColor) {
        self.position = CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.lon)
        self.tintColor = tintColor
        self.workplaceUuid = pin.workplaceUuid
        self.shouldShowView = true
    }
}
