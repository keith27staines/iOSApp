//
//  CompanyJson.swift
//  CompanyList
//
//  Created by Keith Dev on 22/03/2020.
//  Copyright © 2020 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

struct CompanyListJson: Codable {
    var count: Int
    var next: String?
    var previous: String?
    var results: [CompanyJson]
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
