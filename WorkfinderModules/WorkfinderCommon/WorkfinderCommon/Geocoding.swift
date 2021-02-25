//
//  Geocoding.swift
//  WorkfinderCommon
//
//  Created by Keith Staines on 18/02/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import Foundation
import CoreLocation

//func zipToAddress(zip: String, onSuccess: @escaping (String, String, String) -> Void, onFail: @escaping () -> Void) {
//    let geoCoder = CLGeocoder();
//
//    let params = [
//        String(CLPostalAddress.PostalCodeKey): zip,
//        String(CNPostalAddressPostalCodeKey): "US",
//        ]
//
//    geoCoder.geocodeAddressDictionary(params) {
//        (plasemarks, error) -> Void in
//
//        if let plases = plasemarks {
//
//            if plases.count > 0 {
//                let firstPlace = plases[0]
//
//                print( "City \(firstPlace.locality) state \(firstPlace.administrativeArea) and country \(firstPlace.country) and iso country \(firstPlace.country)")
//
//                let city = firstPlace.locality
//                let state = firstPlace.administrativeArea
//                let country = firstPlace.country
//
//                onSuccess(city != nil ? city! : "", state != nil ? state! : "", country ?? "Not found")
//                return;
//            }
//        }
//
//        onFail()
//    }
//}
