//
//  InterviewJsonTests.swift
//  WorkfinderServicesTests
//
//  Created by Keith on 14/09/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import XCTest
import WorkfinderServices

class InterviewJsonTests: XCTestCase {
    
    func test_IntervewDate_decode() throws {
        let jsonData = interviewDateJsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let result = try decoder.decode(InterviewJson.InterviewDateJson.self, from: jsonData)
        XCTAssertEqual(result.id, 10)
        XCTAssertEqual(result.dateTime, "2021-09-14T13:15:00.108000Z")
    }
    
    func test_Company_decode() throws {
        let jsonData = companyJsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let result = try decoder.decode(InterviewJson.PlacementJson.CompanyJson.self, from: jsonData)
        XCTAssertEqual(result.name, "Workfinder Limited")
    }
    
    func test_Location_decode() throws {
        let jsonData = locationJsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let result = try decoder.decode(InterviewJson.PlacementJson.LocationJson.self, from: jsonData)
        XCTAssertEqual(result.addressCity, "London")
    }
    
    func test_Placement_decode() throws {
        let jsonData = placementJsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let result = try decoder.decode(InterviewJson.PlacementJson.self, from: jsonData)
        XCTAssertEqual(result.id, 903)
    }
    
    func test_Association_decode() throws {
        let jsonData = associationJsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let result = try decoder.decode(InterviewJson.PlacementJson.AssociationJson.self, from: jsonData)
        XCTAssertEqual(result.host?.fullname, "Keith Staines")
    }
    
    func test_Project_decode() throws {
        let jsonData = projectJsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let result = try decoder.decode(InterviewJson.PlacementJson.ProjectJson.self, from: jsonData)
        XCTAssertEqual(result.duration, "2 weeks")
    }

    func test_InterviewJson_decode() throws {
        let jsonData = interviewJsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let result = try decoder.decode(InterviewJson.self, from: jsonData)
        XCTAssertEqual(result.id, 11)
    }

}

let projectJsonString = """
                  {
                    \"candidates_requested\" : \"1\",
                    \"employment_type\" : \"Full-time\",
                    \"promote_on_home_page\" : false,
                    \"status\" : \"open\",
                    \"role_type\" : \"Work Experience\",
                    \"duration\" : \"2 weeks\",
                    \"host_activities\" : [

                    ],
                    \"voluntary_reason\" : \"\",
                    \"end_date\" : null,
                    \"skills_acquired\" : [
                      \"dodging photon torpedos\",
                      \"socialising with androids\",
                      \"astronavigation\"
                    ],
                    \"uuid\" : \"b7ef25c3-19dd-4f8d-9fd6-3b973bb435a5\",
                    \"is_remote\" : false,
                    \"association\" : \"48551e61-dd13-40dc-a517-d0b77f295412\",
                    \"salary\" : 100,
                    \"name\" : \"Starship Pilot\",
                    \"is_candidate_location_required\" : true,
                    \"about_candidate\" : \"You are calm in the face of alien insurrection\",
                    \"type\" : \"Bespoke\",
                    \"is_paid\" : true,
                    \"additional_comments\" : \"These are my additional comments\",
                    \"application_count\" : 1,
                    \"candidate_activities\" : [
                      \"avoiding phasor fire\",
                      \"proper use of force field\",
                      \"negotiation with Borg\"
                    ],
                    \"start_date\" : \"2021-10-04\",
                    \"created_at\" : \"2021-09-14T13:09:40.348108Z\",
                    \"minimum_education\" : \"MA\",
                    \"description\" : \"You will learn to drive at warp speed between the stars\"
                  }
    """

let associationJsonString = """
                  {
                    \"host\" : {
                      \"full_name\" : \"Keith Staines\",
                      \"emails\" : [
                        \"keith.staines+host@workfinder.com\",
                        \"keith.staines@workfinder.com\",
                        \"keith27staines@icloud.com\"
                      ],
                      \"photo\" : \"photoUrl\",
                      \"uuid\" : \"51464079-921b-4d41-9a65-95f1bed758bf\"
                    },
                    \"location\" : {
                      \"address_city\" : \"London\",
                      \"address_street\" : \"1000 Hello X Music Llp 27 Old Gloucester Street\",
                      \"address_building\" : \"\",
                      \"company\" : {
                        \"logo\" : null,
                        \"industries\" : [
    
                        ],
                        \"name\" : \"Workfinder Limited\",
                        \"uuid\" : \"a429fb52-84e0-4f01-aca5-f6b21e5b049d\"
                      },
                      \"uuid\" : \"e90cd333-ad27-456e-a2da-258f3f2bce18\",
                      \"address_unit\" : \"\",
                      \"address_region\" : \"Greater London\",
                      \"address_country\" : {
                        \"name\" : \"United Kingdom\",
                        \"code\" : \"GB\"
                      },
                      \"address_postcode\" : \"WC1N3AX\"
                    }
                  }
    """

let placementJsonString = """
            {
              \"id\" : 903,
              \"uuid\" : \"3ad74873-72ba-4ef0-96cd-c9b0bba74eb0\",
              \"start_date\" : null,
              \"offered_duration\" : null,
              \"reason_withdrawn_other\" : \"\",
              \"created_at\" : \"2021-09-14T13:10:45.727932Z\",
              \"associated_project\" : {
                \"candidates_requested\" : \"1\",
                \"employment_type\" : \"Full-time\",
                \"promote_on_home_page\" : false,
                \"status\" : \"open\",
                \"role_type\" : \"Work Experience\",
                \"duration\" : \"2 weeks\",
                \"host_activities\" : [

                ],
                \"voluntary_reason\" : \"\",
                \"end_date\" : null,
                \"skills_acquired\" : [
                  \"dodging photon torpedos\",
                  \"socialising with androids\",
                  \"astronavigation\"
                ],
                \"uuid\" : \"b7ef25c3-19dd-4f8d-9fd6-3b973bb435a5\",
                \"is_remote\" : false,
                \"association\" : \"48551e61-dd13-40dc-a517-d0b77f295412\",
                \"salary\" : 100,
                \"name\" : \"Starship Pilot\",
                \"is_candidate_location_required\" : true,
                \"about_candidate\" : \"You are calm in the face of alien insurrection\",
                \"type\" : \"Bespoke\",
                \"is_paid\" : true,
                \"additional_comments\" : \"These are my additional comments\",
                \"application_count\" : 1,
                \"candidate_activities\" : [
                  \"avoiding phasor fire\",
                  \"proper use of force field\",
                  \"negotiation with Borg\"
                ],
                \"start_date\" : \"2021-10-04\",
                \"created_at\" : \"2021-09-14T13:09:40.348108Z\",
                \"minimum_education\" : \"MA\",
                \"description\" : \"You will learn to drive at warp speed between the stars\"
              },
              \"end_date\" : null,
              \"reason_withdrawn\" : null,
              \"reason_declined\" : null,
              \"association\" : {
                \"host\" : {
                  \"full_name\" : \"Keith Staines\",
                  \"emails\" : [
                    \"keith.staines+host@workfinder.com\",
                    \"keith.staines@workfinder.com\",
                    \"keith27staines@icloud.com\"
                  ],
                  \"photo\" : \"photoUrl\",
                  \"uuid\" : \"51464079-921b-4d41-9a65-95f1bed758bf\"
                },
                \"location\" : {
                  \"address_city\" : \"London\",
                  \"address_street\" : \"1000 Hello X Music Llp 27 Old Gloucester Street\",
                  \"address_building\" : \"\",
                  \"company\" : {
                    \"logo\" : null,
                    \"industries\" : [

                    ],
                    \"name\" : \"Workfinder Limited\",
                    \"uuid\" : \"a429fb52-84e0-4f01-aca5-f6b21e5b049d\"
                  },
                  \"uuid\" : \"e90cd333-ad27-456e-a2da-258f3f2bce18\",
                  \"address_unit\" : \"\",
                  \"address_region\" : \"Greater London\",
                  \"address_country\" : {
                    \"name\" : \"United Kingdom\",
                    \"code\" : \"GB\"
                  },
                  \"address_postcode\" : \"WC1N3AX\"
                }
              },
              \"offer_notes\" : \"\",
              \"reason_declined_other\" : \"\",
              \"status\" : \"interview offered\"
            }
    """

let locationJsonString = """
    {
      \"address_city\" : \"London\",
      \"address_street\" : \"1000 Hello X Music Llp 27 Old Gloucester Street\",
      \"address_building\" : \"\",
      \"company\" : {
        \"logo\" : null,
        \"industries\" : [

        ],
        \"name\" : \"Workfinder Limited\",
        \"uuid\" : \"a429fb52-84e0-4f01-aca5-f6b21e5b049d\"
      },
      \"uuid\" : \"e90cd333-ad27-456e-a2da-258f3f2bce18\",
      \"address_unit\" : \"\",
      \"address_region\" : \"Greater London\",
      \"address_country\" : {
        \"name\" : \"United Kingdom\",
        \"code\" : \"GB\"
      },
      \"address_postcode\" : \"WC1N3AX\"
    }
  """

let companyJsonString = """
    {
      \"logo\" : null,
      \"industries\" : [

      ],
      \"name\" : \"Workfinder Limited\",
      \"uuid\" : \"a429fb52-84e0-4f01-aca5-f6b21e5b049d\"
    }
    """

let interviewDateJsonString = """
      {
        \"date_time\" : \"2021-09-14T13:15:00.108000Z\",
        \"id\" : 10,
        \"interview\" : 10,
        \"status\" : \"open\",
        \"time_str\" : \"14:15 - 14:30\",
        \"duration\" : 15
      }
    """

let interviewJsonString = """
      {
        \"status\" : \"interview_offered\",
        \"meeting_link\" : null,
        \"offer_end_date\" : null,
        \"id\" : 11,
        \"placement\" : {
          \"id\" : 903,
          \"uuid\" : \"3ad74873-72ba-4ef0-96cd-c9b0bba74eb0\",
          \"start_date\" : null,
          \"offered_duration\" : null,
          \"reason_withdrawn_other\" : \"\",
          \"created_at\" : \"2021-09-14T13:10:45.727932Z\",
          \"associated_project\" : {
            \"candidates_requested\" : \"1\",
            \"employment_type\" : \"Full-time\",
            \"promote_on_home_page\" : false,
            \"status\" : \"open\",
            \"role_type\" : \"Work Experience\",
            \"duration\" : \"2 weeks\",
            \"host_activities\" : [

            ],
            \"voluntary_reason\" : \"\",
            \"end_date\" : null,
            \"skills_acquired\" : [
              \"dodging photon torpedos\",
              \"socialising with androids\",
              \"astronavigation\"
            ],
            \"uuid\" : \"b7ef25c3-19dd-4f8d-9fd6-3b973bb435a5\",
            \"is_remote\" : false,
            \"association\" : \"48551e61-dd13-40dc-a517-d0b77f295412\",
            \"salary\" : 100,
            \"name\" : \"Starship Pilot\",
            \"is_candidate_location_required\" : true,
            \"about_candidate\" : \"You are calm in the face of alien insurrection\",
            \"type\" : \"Bespoke\",
            \"is_paid\" : true,
            \"additional_comments\" : \"These are my additional comments\",
            \"application_count\" : 1,
            \"candidate_activities\" : [
              \"avoiding phasor fire\",
              \"proper use of force field\",
              \"negotiation with Borg\"
            ],
            \"start_date\" : \"2021-10-04\",
            \"created_at\" : \"2021-09-14T13:09:40.348108Z\",
            \"minimum_education\" : \"MA\",
            \"description\" : \"You will learn to drive at warp speed between the stars\"
          },
          \"end_date\" : null,
          \"reason_withdrawn\" : null,
          \"reason_declined\" : null,
          \"association\" : {
            \"host\" : {
              \"full_name\" : \"Keith Staines\",
              \"emails\" : [
                \"keith.staines+host@workfinder.com\",
                \"keith.staines@workfinder.com\",
                \"keith27staines@icloud.com\"
              ],
              \"photo\" : \"photoUrl\",
              \"uuid\" : \"51464079-921b-4d41-9a65-95f1bed758bf\"
            },
            \"location\" : {
              \"address_city\" : \"London\",
              \"address_street\" : \"1000 Hello X Music Llp 27 Old Gloucester Street\",
              \"address_building\" : \"\",
              \"company\" : {
                \"logo\" : null,
                \"industries\" : [

                ],
                \"name\" : \"Workfinder Limited\",
                \"uuid\" : \"a429fb52-84e0-4f01-aca5-f6b21e5b049d\"
              },
              \"uuid\" : \"e90cd333-ad27-456e-a2da-258f3f2bce18\",
              \"address_unit\" : \"\",
              \"address_region\" : \"Greater London\",
              \"address_country\" : {
                \"name\" : \"United Kingdom\",
                \"code\" : \"GB\"
              },
              \"address_postcode\" : \"WC1N3AX\"
            }
          },
          \"offer_notes\" : \"\",
          \"reason_declined_other\" : \"\",
          \"status\" : \"interview offered\"
        },
        \"additional_offer_note\" : null,
        \"uuid\" : \"24237339-ed6e-455e-846a-25c15b87edcc\",
        \"offer_message\" : \"Hi K. S. Thank you for applying for a position with us via Workfinder, we would like to progress your application and we are offering to interview you via video at the following time(s). We hope that you are available and look forward to seeing you, if you are. Looking forward to speaking with you.\",
        \"interview_dates\" : [
          {
            \"date_time\" : \"2021-09-14T13:15:00.108000Z\",
            \"id\" : 10,
            \"interview\" : 10,
            \"status\" : \"open\",
            \"time_str\" : \"14:15 - 14:30\",
            \"duration\" : 15
          }
        ],
        \"candidate\" : 2689,
        \"offer_starting_date\" : null
      }
    """
