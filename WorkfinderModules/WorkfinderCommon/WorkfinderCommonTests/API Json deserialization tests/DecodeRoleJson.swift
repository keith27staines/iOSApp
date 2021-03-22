
import XCTest
@testable import WorkfinderCommon

class DecodeRoleJsonTests: XCTestCase {
    
    let roleJsonData = roleJsonString.data(using: .utf8)!
    let roleNestedAssociationData = roleNestedAssociationString.data(using: .utf8)!
    
    func test_decodeRoleNestedAssociation() {
        let decoder = JSONDecoder()
        do {
            let sut = try decoder.decode(RoleNestedAssociation.self, from: roleNestedAssociationData)
            XCTAssertEqual(sut.uuid,"e27dd6f0-ce70-47e1-9a34-d45c95ba2ddf")
        } catch {
            print(error)
            XCTFail()
        }

    }
}

let roleNestedAssociationString = """
      {
        \"title\" : \"Product Design (UX/UI/Digital Design)\",
        \"host\" : {
          \"uuid\" : \"fddc9d89-b379-467c-9eac-a6d206c49c49\",
          \"full_name\" : \"Arvind Lall\",
          \"description\" : \"I am a multi-disciplinary designer.\",
          \"phone\" : \"07947728711\",
          \"associations\" : [
            \"e27dd6f0-ce70-47e1-9a34-d45c95ba2ddf\"
          ],
          \"photo_thumbnails\" : {
            \"m\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/fddc9d89-b379-467c-9eac-a6d206c49c49.jpg.512x512_q85.jpg\",
            \"s-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/fddc9d89-b379-467c-9eac-a6d206c49c49.jpg.256x256_q85_crop.jpg\",
            \"s\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/fddc9d89-b379-467c-9eac-a6d206c49c49.jpg.256x256_q85.jpg\",
            \"l-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/fddc9d89-b379-467c-9eac-a6d206c49c49.jpg.1024x1024_q85_crop.jpg\",
            \"l\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/fddc9d89-b379-467c-9eac-a6d206c49c49.jpg.1024x1024_q85.jpg\",
            \"m-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/fddc9d89-b379-467c-9eac-a6d206c49c49.jpg.512x512_q85_crop.jpg\"
          },
          \"names\" : [
            \"Arvind Lall\"
          ],
          \"twitter_handle\" : \"\",
          \"linkedin_url\" : \"https://linkedin.com/in/arvindlall\",
          \"friendly_name\" : \"Arvind\",
          \"emails\" : [
            \"arvind.lall@wunderman.com\",
            \"arvind.lall.studio@gmail.com\"
          ],
          \"instagram_handle\" : \"\",
          \"user\" : \"5b0731c6-cc44-466d-a34c-a72fc1d994ea\",
          \"photo\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/hosts/derived/fddc9d89-b379-467c-9eac-a6d206c49c49.jpg\",
          \"opted_into_marketing\" : false
        },
        \"location\" : {
          \"address_city\" : \"London\",
          \"address_street\" : \"13 Trinity Church Square Southwark\",
          \"address_building\" : \"\",
          \"company\" : {
            \"name\" : \"Workfonder\",
            \"logo\" : null,
            \"uuid\" : \"e0d2bf44-a1aa-4368-b876-a12c6be714ea\"
          },
          \"uuid\" : \"0a110f33-ac8e-413c-a6da-e309d9faf9ae\",
          \"address_unit\" : \"\",
          \"address_region\" : \"\",
          \"address_country\" : \"GB\",
          \"address_postcode\" : \"SE1 4HU\"
        },
        \"uuid\" : \"e27dd6f0-ce70-47e1-9a34-d45c95ba2ddf\"
      }
"""

let roleJsonString = """
    {
      \"candidates_requested\" : \"1\",
      \"status\" : \"open\",
      \"employment_type\" : \"Full-time\",
      \"promote_on_home_page\" : false,
      \"duration\" : \"\",
      \"host_activities\" : [

      ],
      \"skills_acquired\" : [
        \"Competitor Analysis\",
      ],
      \"uuid\" : \"32a82c14-eeb6-4aea-b93e-15a191e19c0c\",
      \"is_remote\" : true,
      \"association\" : {
        \"title\" : \"Product Design (UX/UI/Digital Design)\",
        \"host\" : {
          \"uuid\" : \"fddc9d89-b379-467c-9eac-a6d206c49c49\",
          \"full_name\" : \"Arvind Lall\",
          \"description\" : \"I am a multi-disciplinary designer.\",
          \"phone\" : \"07947728711\",
          \"associations\" : [
            \"e27dd6f0-ce70-47e1-9a34-d45c95ba2ddf\"
          ],
          \"photo_thumbnails\" : {
            \"m\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/fddc9d89-b379-467c-9eac-a6d206c49c49.jpg.512x512_q85.jpg\",
            \"s-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/fddc9d89-b379-467c-9eac-a6d206c49c49.jpg.256x256_q85_crop.jpg\",
            \"s\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/fddc9d89-b379-467c-9eac-a6d206c49c49.jpg.256x256_q85.jpg\",
            \"l-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/fddc9d89-b379-467c-9eac-a6d206c49c49.jpg.1024x1024_q85_crop.jpg\",
            \"l\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/fddc9d89-b379-467c-9eac-a6d206c49c49.jpg.1024x1024_q85.jpg\",
            \"m-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/fddc9d89-b379-467c-9eac-a6d206c49c49.jpg.512x512_q85_crop.jpg\"
          },
          \"names\" : [
            \"Arvind Lall\"
          ],
          \"twitter_handle\" : \"\",
          \"linkedin_url\" : \"https://linkedin.com/in/arvindlall\",
          \"friendly_name\" : \"Arvind\",
          \"emails\" : [
            \"arvind.lall@wunderman.com\",
            \"arvind.lall.studio@gmail.com\"
          ],
          \"instagram_handle\" : \"\",
          \"user\" : \"5b0731c6-cc44-466d-a34c-a72fc1d994ea\",
          \"photo\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/hosts/derived/fddc9d89-b379-467c-9eac-a6d206c49c49.jpg\",
          \"opted_into_marketing\" : false
        },
        \"location\" : {
          \"address_city\" : \"London\",
          \"address_street\" : \"13 Trinity Church Square Southwark\",
          \"address_building\" : \"\",
          \"company\" : {
            \"name\" : \"Workfonder\",
            \"logo\" : null,
            \"uuid\" : \"e0d2bf44-a1aa-4368-b876-a12c6be714ea\"
          },
          \"uuid\" : \"0a110f33-ac8e-413c-a6da-e309d9faf9ae\",
          \"address_unit\" : \"\",
          \"address_region\" : \"\",
          \"address_country\" : \"GB\",
          \"address_postcode\" : \"SE1 4HU\"
        },
        \"uuid\" : \"e27dd6f0-ce70-47e1-9a34-d45c95ba2ddf\"
      },
      \"name\" : \"Competitor Analysis Review\",
      \"type\" : \"Competitor Analysis Review\",
      \"about_candidate\" : \"\",
      \"is_paid\" : false,
      \"additional_comments\" : \"\",
      \"application_count\" : 0,
      \"candidate_activities\" : [

      ],
      \"start_date\" : null,
      \"created_at\" : \"2020-12-03T14:39:43.510052Z\",
      \"description\" : \"We’re looking for students to complete a short work placement focused on conducting a competitor analysis. You’ll be responsible for identifying the main competitors, creating benchmarks for comparison, and identifying opportunity areas for growth. Working alongside the commercial or management side of the business you’ll have the chance to hone your skills and learn more about working on the strategy side of a business whilst adding real value.\"
    }
"""
