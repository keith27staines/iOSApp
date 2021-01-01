

import XCTest
@testable import WorkfinderCommon

class DecodeCompanyJsonTests: XCTestCase {

    let companyData = companyString.data(using: .utf8)!
    let locationData = locationString.data(using: .utf8)!
    
    func test_decodeCompany() {
        let decoder = JSONDecoder()
        let sut = try? decoder.decode(CompanyJson.self, from: companyData)
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut?.locations?.first?.addressPostcode, "WC1N 3AX")
    }
    
    func test_decodeLCompanyNestedLocationJson() {
        let decoder = JSONDecoder()
        let sut = try? decoder.decode(CompanyNestedLocationJson.self, from: locationData)
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut?.companyUuid, "d3ec9374-3618-4617-9ff6-535c40a7be46")
        XCTAssertEqual(sut?.addressPostcode, "WC1N 3AX")
    }
    

}

let locationString = """
    {
      \"uuid\" : \"21213011-061b-46fc-87e8-17886ebc0a5c\",
      \"address_region\" : \"Greater London\",
      \"address_city\" : \"London\",
      \"company\" : \"d3ec9374-3618-4617-9ff6-535c40a7be46\",
      \"type\" : \"registered\",
      \"address_building\" : \"\",
      \"address_street\" : \"Tea building 27 Old Gloucester Street\",
      \"last_geocode_attempt\" : \"2020-08-19T09:56:43.523223Z\",
      \"address_unit\" : \"\",
      \"geometry\" : {
        \"type\" : \"Point\",
        \"coordinates\" : [
          -0.12217649999999999,
          51.520591099999997
        ]
      },
      \"address_country\" : {
        \"name\" : \"United Kingdom\",
        \"code\" : \"GB\"
      },
      \"address_postcode\" : \"WC1N 3AX\"
    }
"""


let companyString = """
{
  \"names\" : [
    \"Workfinder\"
  ],
  \"industries\" : [

  ],
  \"domains\" : [
    \"workfinder.com\"
  ],
  \"status\" : \"active\",
  \"emails\" : [

  ],
  \"lei\" : \"\",
  \"instagram_handles\" : [

  ],
  \"logo_thumbnails\" : null,
  \"ebitda\" : null,
  \"uuid\" : \"d3ec9374-3618-4617-9ff6-535c40a7be46\",
  \"name\" : \"Workfinder\",
  \"twitter_handles\" : [

  ],
  \"locations\" : [
    {
      \"uuid\" : \"21213011-061b-46fc-87e8-17886ebc0a5c\",
      \"address_region\" : \"Greater London\",
      \"address_city\" : \"London\",
      \"company\" : \"d3ec9374-3618-4617-9ff6-535c40a7be46\",
      \"type\" : \"registered\",
      \"address_building\" : \"\",
      \"address_street\" : \"Tea building 27 Old Gloucester Street\",
      \"last_geocode_attempt\" : \"2020-08-19T09:56:43.523223Z\",
      \"address_unit\" : \"\",
      \"geometry\" : {
        \"type\" : \"Point\",
        \"coordinates\" : [
          -0.12217649999999999,
          51.520591099999997
        ]
      },
      \"address_country\" : {
        \"name\" : \"United Kingdom\",
        \"code\" : \"GB\"
      },
      \"address_postcode\" : \"WC1N 3AX\"
    }
  ],
  \"growth\" : null,
  \"turnover\" : null,
  \"duedil_url\" : null,
  \"phone_numbers\" : [

  ],
  \"footprint\" : null,
  \"logo\" : null,
  \"employee_count\" : null,
  \"description\" : \"\"
}
"""
