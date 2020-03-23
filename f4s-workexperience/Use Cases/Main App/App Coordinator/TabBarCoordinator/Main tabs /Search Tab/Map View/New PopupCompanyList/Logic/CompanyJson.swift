//
//  CompanyJson.swift
//  CompanyList
//
//  Created by Keith Dev on 22/03/2020.
//  Copyright © 2020 Founders4Schools. All rights reserved.
//

import Foundation

struct CompanyListJson: Codable {
    var count: Int
    var next: String?
    var previous: String?
    var results: [CompanyJson]
}

struct CompanyJson: Codable {
    var uuid: String?
    var name: String?
    var description: String?
    var logoUrlString: String?
    var duedilUrlString: String?
    
    private enum codingKeys: String, CodingKey {
        case uuid
        case name
        case description
        case logo
        case duedilUrlString = "duedil_url"
    }
}

struct CompanyLocationJson: Codable {
    var uuid: String?
    var postcode: String?
    var point: String?
    private enum codingKeys: String, CodingKey {
        case uuid
        case postcode = "address_postcode"
        case point
    }
}

/* Structure returned from companies endpoint
{
  "uuid": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "name": "string",
  "names": [
    "string"
  ],
  "domains": [
    null
  ],
  "logo": "string",
  "description": "string",
  "industries": [
    null
  ],
  "emails": [
    "user@example.com"
  ],
  "phone_numbers": [
    null
  ],
  "twitter_handles": [
    "string"
  ],
  "instagram_handles": [
    "string"
  ],
  "duedil_url": "string",
  "footprint": "string",
  "locations": [
    {
      "uuid": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "address_unit": "string",
      "address_building": "string",
      "address_street": "string",
      "address_city": "string",
      "address_region": "string",
      "address_country": "string",
      "address_postcode": "string",
      "point": "string",
      "last_geocode_attempt": "2020-03-22T11:53:35.140Z"
    }
  ]
}
*/
