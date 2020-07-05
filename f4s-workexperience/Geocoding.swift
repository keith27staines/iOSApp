//
//  Geocoding.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 14/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import CoreLocation

func convertLocationToAddress(latitude:Double,longitude:Double){
    
    let geoCoder = CLGeocoder()
    let location = CLLocation(latitude: latitude, longitude: longitude)
    geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
        
        // Place details
        var placeMark: CLPlacemark!
        placeMark = placemarks?[0]
        
        // Location name
        if let locationName = placeMark.location {
            print(locationName)
        }
        // Street address
        if let street = placeMark.thoroughfare {
            print(street)
        }
        // City
        if let city = placeMark.subAdministrativeArea {
            print(city)
        }
        // Zip code
        if let zip = placeMark.isoCountryCode {
            print(zip)
        }
        // Country
        if let country = placeMark.country {
            print(country)
        }
    })
    
}
