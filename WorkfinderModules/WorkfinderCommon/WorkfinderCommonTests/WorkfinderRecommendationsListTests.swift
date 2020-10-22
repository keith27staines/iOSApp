
import XCTest
import WorkfinderCommon

@testable import WorkfinderCommon

class WorkfinderRecommendationsListTests: XCTestCase {
    
    var recommendationItemData: Data!
    
    override func setUp() {
        recommendationItemData = recommendationsServerList.data(using: .utf8)
    }
    
    func test_decode_recommendation() throws {
        let sut = try JSONDecoder().decode(ServerListJson<RecommendationsListItem>.self, from: recommendationItemData)
        let recommendation = sut.results.first!
        let association = recommendation.association!
        XCTAssertEqual(sut.count, 1)
        XCTAssertEqual(recommendation.uuid, "298a5d09-a347-4857-bd71-d16e2167820d")
        XCTAssertEqual(association.title, "Head of Programme Delivery")
    }

}

fileprivate let recommendationsServerList =
"""
{
  \"count\" : 1,
  \"next\" : null,
  \"previous\" : null,
  \"results\" : [
    {
      \"association\" : {
        \"title\" : \"Head of Programme Delivery\",
        \"host\" : {
          \"uuid\" : \"8f9605f7-52e5-4659-a469-9769a42a64f8\",
          \"full_name\" : \"Skye Willis\",
          \"description\" : \"Description of host\",
          \"phone\" : \"02084197915\",
          \"associations\" : [
            \"23386d60-3502-403c-81ef-97bf1c74da0e\"
          ],
          \"names\" : [
            \"Skye Willis\"
          ],
          \"twitter_handle\" : \"\",
          \"linkedin_url\" : \"https://linkedin.com/in/skyewillis\",
          \"friendly_name\" : \"\",
          \"emails\" : [
            \"skye.willis@workfinder.com\",
            \"skyewillis2019@gmail.com\"
          ],
          \"instagram_handle\" : \"\",
          \"user\" : \"6b850db3-0736-47f8-b907-e8739ab4c322\",
          \"photo\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/hosts/derived/8f9605f7-52e5-4659-a469-9769a42a64f8.jpg\",
          \"opted_into_marketing\" : false
        },
        \"location\" : {
          \"address_city\" : \"London\",
          \"address_street\" : \"27 Old Gloucester Street\",
          \"address_building\" : \"\",
          \"company\" : {
            \"name\" : \"Workfinder\",
            \"logo\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/companies/derived/e4136dc1-22f7-4025-8389-081c9480c322.png\",
            \"uuid\" : \"e4136dc1-22f7-4025-8389-081c9480c322\"
          },
          \"uuid\" : \"d8393335-10ce-433e-96a4-c1c8b0a1b2ba\",
          \"address_unit\" : \"\",
          \"address_region\" : \"\",
          \"address_country\" : \"GB\",
          \"address_postcode\" : \"WC1N 3AX\"
        }
      },
      \"sent_at\" : \"2020-10-18T06:06:08.323920Z\",
      \"confidence\" : 0.66397992351801505,
      \"created_at\" : \"2020-10-16T06:06:09.415750Z\",
      \"uuid\" : \"298a5d09-a347-4857-bd71-d16e2167820d\",
      \"user\" : \"249a185a-a62b-4c93-b4b3-7169bd01f131\",
      \"project\" : {
        \"is_remote\" : true,
        \"host_activities\" : [
          \"UX analysis of current product\",
          \"Test scenario of specific feature\",
          \"Proposal of UX improvements\",
          \"Concept design and wireframing\"
        ],
        \"start_date\" : null,
        \"is_paid\" : true,
        \"uuid\" : \"abaccddc-7ba8-448d-a466-974aef0bac75\",
        \"duration\" : \"\",
        \"description\" : \"Description of the project.\",
        \"type\" : \"UX Testing and Analysis\",
        \"name\" : \"UX Testing and Analysis\",
        \"association\" : {
          \"title\" : \"Head of Programme Delivery\",
          \"host\" : {
            \"uuid\" : \"8f9605f7-52e5-4659-a469-9769a42a64f8\",
            \"full_name\" : \"Skye Willis\",
            \"description\" : \"Description of host.\",
            \"phone\" : \"02084197915\",
            \"associations\" : [
              \"23386d60-3502-403c-81ef-97bf1c74da0e\"
            ],
            \"names\" : [
              \"Skye Willis\"
            ],
            \"twitter_handle\" : \"\",
            \"linkedin_url\" : \"https://linkedin.com/in/skyewillis\",
            \"friendly_name\" : \"\",
            \"emails\" : [
              \"skye.willis@workfinder.com\",
              \"skyewillis2019@gmail.com\"
            ],
            \"instagram_handle\" : \"\",
            \"user\" : \"6b850db3-0736-47f8-b907-e8739ab4c322\",
            \"photo\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/hosts/derived/8f9605f7-52e5-4659-a469-9769a42a64f8.jpg\",
            \"opted_into_marketing\" : false
          },
          \"location\" : {
            \"address_city\" : \"London\",
            \"address_street\" : \"27 Old Gloucester Street\",
            \"address_building\" : \"\",
            \"company\" : {
              \"name\" : \"Workfinder\",
              \"logo\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/companies/derived/e4136dc1-22f7-4025-8389-081c9480c322.png\",
              \"uuid\" : \"e4136dc1-22f7-4025-8389-081c9480c322\"
            },
            \"uuid\" : \"d8393335-10ce-433e-96a4-c1c8b0a1b2ba\",
            \"address_unit\" : \"\",
            \"address_region\" : \"\",
            \"address_country\" : \"GB\",
            \"address_postcode\" : \"WC1N 3AX\"
          }
        }
      }
    }
  ]
}
"""
