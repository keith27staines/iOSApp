//
//  UKAddress.swift
//  WorkfinderCoordinators
//
//  Created by Keith Staines on 18/03/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import Foundation


/*
 {  "result": "Success",  "callsRemaining": 2928,  "creditsRemaining": 74928,  "latitude": "51.503540",  "longitude": "-0.127695",  "expandedAddress": {   "house": "10",   "street": "Downing street",   "locality": "",   "town": "London",   "district": "Greater london",   "county": "London",   "pCode": "SW1A 2AA"  },  "csvAddress": "10,Downing street,,London,Greater london,London,SW1A 2AA",  "statusCode": "200" }
 */

public struct UKAddress: Codable {
    public var house: String?
    public var street: String?
    public var locality: String?
    public var town: String?
    public var district: String?
    public var county: String?
    public var postcode: String?
    
    public init(
        house: String?,
        street: String?,
        locality: String?,
        town: String?,
        district: String?,
        county: String?,
        postcode: String?
    ) {
        self.house = house
        self.street = street
        self.locality = locality
        self.town = town
        self.district = district
        self.county = county
        self.postcode = postcode
    }
}

public struct FindAddressResponse: Decodable {
    public var result: String?
    public var expandedAddress: UKAddress?
    public var csvAddress: String?
    public var statusCode: String?
    public var errorMsg: String?
}

