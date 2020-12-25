
import XCTest
import WorkfinderCommon

@testable import WorkfinderCommon

class DecodeRecommendationsListTests: XCTestCase {
    
    var recommendationItemData: Data!
    
    override func setUp() {
        recommendationItemData = recommendationsServerList.data(using: .utf8)
    }
    
    func test_decode_recommendation() throws {
        let sut = try JSONDecoder().decode(ServerListJson<RecommendationsListItem>.self, from: recommendationItemData)
        let recommendation = sut.results.first!
        let association = recommendation.association!
        XCTAssertEqual(sut.count, 1)
        XCTAssertEqual(recommendation.uuid, "f8408e02-563a-49c5-bf5f-f0788f5a7417")
        XCTAssertEqual(association.title, "Senior Developer at Workfinder")
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
        \"title\" : \"Senior Developer at Workfinder\",
        \"host\" : {
          \"uuid\" : \"b08b8360-1cd5-4547-a985-fdd8b2039975\",
          \"full_name\" : \"Stu Burgoyne\",
          \"description\" : \"Freelance Developer and Director of Script This Ltd\",
          \"phone\" : \"01234567890\",
          \"associations\" : [
            \"39c90daf-2a06-4632-b5dd-7bf3ae2354b3\"
          ],
          \"photo_thumbnails\" : {
            \"m\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/b08b8360-1cd5-4547-a985-fdd8b2039975.jpg.512x512_q85.jpg\",
            \"s-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/b08b8360-1cd5-4547-a985-fdd8b2039975.jpg.256x256_q85_crop.jpg\",
            \"s\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/b08b8360-1cd5-4547-a985-fdd8b2039975.jpg.256x256_q85.jpg\",
            \"l-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/b08b8360-1cd5-4547-a985-fdd8b2039975.jpg.1024x1024_q85_crop.jpg\",
            \"l\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/b08b8360-1cd5-4547-a985-fdd8b2039975.jpg.1024x1024_q85.jpg\",
            \"m-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/b08b8360-1cd5-4547-a985-fdd8b2039975.jpg.512x512_q85_crop.jpg\"
          },
          \"names\" : [
            \"Stu Burgoyne\"
          ],
          \"twitter_handle\" : \"\",
          \"linkedin_url\" : \"https://linkedin.com/in/stuartburgoyne\",
          \"friendly_name\" : \"Stu\",
          \"emails\" : [
            \"stu@script-this.co.uk\"
          ],
          \"instagram_handle\" : \"\",
          \"user\" : \"21d180ba-4479-4718-aa17-610f9178d62c\",
          \"photo\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/hosts/derived/b08b8360-1cd5-4547-a985-fdd8b2039975.jpg\",
          \"opted_into_marketing\" : true
        },
        \"location\" : {
          \"address_city\" : \"Milton Keynes\",
          \"address_street\" : \"Suite 3 Douglas House\",
          \"address_building\" : \"\",
          \"company\" : {
            \"name\" : \"Script This Ltd\",
            \"logo\" : null,
            \"uuid\" : \"cede8981-866a-4edc-86f1-9e790cefc16e\"
          },
          \"uuid\" : \"e999a531-f927-4ee8-88d5-3f617a9584b2\",
          \"address_unit\" : \"\",
          \"address_region\" : \"Buckinghamshire\",
          \"address_country\" : \"GB\",
          \"address_postcode\" : \"MK1 1BA\"
        },
        \"uuid\" : \"39c90daf-2a06-4632-b5dd-7bf3ae2354b3\"
      },
      \"recommender\" : {
        \"scorers\" : [
          {
            \"host_period\" : 90,
            \"placement_period\" : 30,
            \"weight\" : 0.10000000000000001,
            \"class\" : \"ActivityScorer\",
            \"weights\" : {
              \"accepted\" : 0.20000000000000001,
              \"viewed\" : 0.20000000000000001,
              \"created_recently\" : 0.5,
              \"time_since_last_log_in\" : 0.10000000000000001
            }
          },
          {
            \"class\" : \"ProjectBoosterScorer\",
            \"weight\" : 0.14999999999999999
          },
          {
            \"class\" : \"ProjectUCASScorer\",
            \"weight\" : 0.5
          },
          {
            \"class\" : \"ApplicationBiasScorer\",
            \"weight\" : 0.14999999999999999
          },
          {
            \"class\" : \"RecommendationBiasScorer\",
            \"weight\" : 0.10000000000000001
          }
        ],
        \"relevancy\" : 5,
        \"builders\" : [
          {
            \"class\" : \"ProjectsOnlyBuilder\",
            \"description\" : \"Only associations with an open project\"
          }
        ]
      },
      \"sent_at\" : null,
      \"confidence\" : 0.74519225554555901,
      \"created_at\" : \"2020-12-25T10:28:52.524796Z\",
      \"uuid\" : \"f8408e02-563a-49c5-bf5f-f0788f5a7417\",
      \"project\" : {
        \"candidates_requested\" : \"3\",
        \"status\" : \"open\",
        \"employment_type\" : \"Full-time\",
        \"promote_on_home_page\" : false,
        \"duration\" : \"\",
        \"host_activities\" : [

        ],
        \"skills_acquired\" : [

        ],
        \"uuid\" : \"300930ad-d40f-4134-b49c-89cd5856d003\",
        \"is_remote\" : true,
        \"association\" : {
          \"title\" : \"Senior Developer at Workfinder\",
          \"host\" : {
            \"uuid\" : \"b08b8360-1cd5-4547-a985-fdd8b2039975\",
            \"full_name\" : \"Stu Burgoyne\",
            \"description\" : \"Freelance Developer and Director of Script This Ltd\",
            \"phone\" : \"01234567890\",
            \"associations\" : [
              \"39c90daf-2a06-4632-b5dd-7bf3ae2354b3\"
            ],
            \"photo_thumbnails\" : {
              \"m\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/b08b8360-1cd5-4547-a985-fdd8b2039975.jpg.512x512_q85.jpg\",
              \"s-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/b08b8360-1cd5-4547-a985-fdd8b2039975.jpg.256x256_q85_crop.jpg\",
              \"s\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/b08b8360-1cd5-4547-a985-fdd8b2039975.jpg.256x256_q85.jpg\",
              \"l-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/b08b8360-1cd5-4547-a985-fdd8b2039975.jpg.1024x1024_q85_crop.jpg\",
              \"l\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/b08b8360-1cd5-4547-a985-fdd8b2039975.jpg.1024x1024_q85.jpg\",
              \"m-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/b08b8360-1cd5-4547-a985-fdd8b2039975.jpg.512x512_q85_crop.jpg\"
            },
            \"names\" : [
              \"Stu Burgoyne\"
            ],
            \"twitter_handle\" : \"\",
            \"linkedin_url\" : \"https://linkedin.com/in/stuartburgoyne\",
            \"friendly_name\" : \"Stu\",
            \"emails\" : [
              \"stu@script-this.co.uk\"
            ],
            \"instagram_handle\" : \"\",
            \"user\" : \"21d180ba-4479-4718-aa17-610f9178d62c\",
            \"photo\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/hosts/derived/b08b8360-1cd5-4547-a985-fdd8b2039975.jpg\",
            \"opted_into_marketing\" : true
          },
          \"location\" : {
            \"address_city\" : \"Milton Keynes\",
            \"address_street\" : \"Suite 3 Douglas House\",
            \"address_building\" : \"\",
            \"company\" : {
              \"name\" : \"Script This Ltd\",
              \"logo\" : null,
              \"uuid\" : \"cede8981-866a-4edc-86f1-9e790cefc16e\"
            },
            \"uuid\" : \"e999a531-f927-4ee8-88d5-3f617a9584b2\",
            \"address_unit\" : \"\",
            \"address_region\" : \"Buckinghamshire\",
            \"address_country\" : \"GB\",
            \"address_postcode\" : \"MK1 1BA\"
          },
          \"uuid\" : \"39c90daf-2a06-4632-b5dd-7bf3ae2354b3\"
        },
        \"name\" : \"UX Testing and Analysis\",
        \"type\" : \"UX Testing and Analysis\",
        \"about_candidate\" : \"\",
        \"is_paid\" : true,
        \"additional_comments\" : \"\",
        \"application_count\" : 1,
        \"candidate_activities\" : [

        ],
        \"start_date\" : null,
        \"created_at\" : \"2020-11-24T12:02:53.160980Z\",
        \"description\" : \"We are looking for students to complete a short work placement focused on UX testing and analysis. You will be responsible for assessing the UI and overall UX of the product, running through the entire journey. Documenting as you go, you will be able to deliver recommendations and suggestions for improvements. Working alongside the tech and product side of the business you will have the chance to hone your skills and learn more about working on user centric design whilst adding real value to the business.\"
      },
      \"user\" : \"e351b1a3-8b56-4ef4-a674-2d740130bed1\"
    }
  ]
}
"""
