
import XCTest
import WorkfinderCommon

@testable import WorkfinderCommon

class WorkfinderRecommendationsListTests: XCTestCase {
    var recommendationItemString: String!
    var recommendationItemData: Data!
    
    override func setUp() {
        
        recommendationItemString = "{\"uuid\":\"d76e8806-c299-4c4a-98c7-b5a5a71d86be\",\"user\":\"2895edf7-0b3a-4e78-aea1-c26c62e813da\",\"association\":{\"host\":{\"uuid\":\"51464079-921b-4d41-9a65-95f1bed758bf\",\"full_name\":\"Keith Staines\",\"names\":[\"Keith Staines\"],\"emails\":[\"keith27staines+new@icloud.com\",\"keith.staines@workfinder.com\",\"keith27staines@icloud.com\"],\"user\":\"0c622e68-6d8b-427c-929a-ca58ff102a4b\",\"photo\":\"https://api-workfinder-com-develop.s3.amazonaws.com/media/hosts/derived/51464079-921b-4d41-9a65-95f1bed758bf.jpg\",\"phone\":\"07757262284\",\"instagram_handle\":\"\",\"twitter_handle\":\"\",\"linkedin_url\":\"https://linkedin.com/in/keith-s-42b5a8148\",\"description\":\"Originally I trained as a physicist and then worked in nuclear power stations and on space programmes for ESA and NASA. I moved into software development  in 1996. My ideal job would combine physics, mathematics and coding, and that's pretty much what I have been doing for the last few years.\",\"associations\":[\"48551e61-dd13-40dc-a517-d0b77f295412\",\"065845d2-3f9c-412f-b8f3-9374f17e5057\"],\"opted_into_marketing\":false},\"location\":{\"uuid\":\"e90cd333-ad27-456e-a2da-258f3f2bce18\",\"address_unit\":\"\",\"address_building\":\"\",\"address_street\":\"1000 Hello X Music Llp 27 Old Gloucester Street\",\"address_city\":\"London\",\"address_region\":\"Greater London\",\"address_country\":\"GB\",\"address_postcode\":\"WC1N3AX\",\"company\":{\"uuid\":\"a429fb52-84e0-4f01-aca5-f6b21e5b049d\",\"logo\":null,\"name\":\"Workfinder Limited\"}},\"title\":\"iOS Developer at Workfinder LTD\"},\"recommender\":{\"scorers\":[{\"class\":\"DistanceScorer\",\"weight\":0.1},{\"class\":\"ActivityScorer\",\"weight\":0.2,\"weights\":{\"viewed\":0.2,\"accepted\":0.2,\"created_recently\":0.5,\"time_since_last_log_in\":0.1},\"host_period\":90,\"placement_period\":30},{\"class\":\"HostProjectUCASScorer\",\"weight\":0.0},{\"class\":\"ProjectBoosterScorer\",\"weight\":0.25},{\"class\":\"SubjectTagScorer\",\"weight\":0.0},{\"class\":\"ProjectUCASScorer\",\"weight\":0.45}],\"builders\":[{\"class\":\"ProjectsOnlyBuilder\",\"description\":\"Only associations with a project\"},{\"class\":\"GeographicBuilder\",\"max_radius\":10,\"description\":\"Nearest 300 companies within 10 km radius\",\"max_companies\":300}],\"relevancy\":5},\"created_at\":\"2020-09-15T06:06:13.319587Z\",\"sent_at\":\"2020-09-15T06:06:13.527031Z\",\"confidence\":0.627207236926059,\"project\":{\"uuid\":\"d45aa7e3-8c8b-40f1-a6de-c6fbcc334744\",\"type\":{\"uuid\":\"dc3f27f1-f0bb-4d3d-8ce1-e48acc3f9077\",\"name\":\"Web Design\",\"read_more_url\":\"https://develop.workfinder.com/project-resources/\",\"icon\":\"https://api-workfinder-com-develop.s3.amazonaws.com/media/projects/types/07_Proposals_developed_features_for_my_product.png\",\"activities\":[{\"uuid\":\"24c35efb-8695-44d4-b63a-f31df8264a2e\",\"name\":\"Consult on your needs and wants\"},{\"uuid\":\"223dc275-1082-448e-a839-309f24296891\",\"name\":\"Analyse good practice\"},{\"uuid\":\"bece2498-c3fd-4f82-94b8-5782250cbdf2\",\"name\":\"Build a site map\"},{\"uuid\":\"2aff59e4-2a5a-48d8-aaed-651175722e8f\",\"name\":\"UX Wireframing - mobile-first approach\"}],\"skills_acquired\":[\"Web Design\",\"User Research\",\"Product Design\",\"UI Design\"],\"about_candidate\":\"You might have studied web design, computer science, digital product, or similar subjects.\",\"candidate_activities\":[\"Consult multiple stakeholders to get a deep understanding of the business needs.\",\"Analyse the positive elements of any current digital presence and build a site map.\",\"Wireframe new ideas considering responsive design and with a mobile-first approach.\",\"Render mock-ups of each web page (in desktop and mobile) in line with the brand style guides.\",\"Work with the key stakeholders to revise designs as needed.\"],\"description\":\"We’re looking for students to complete a short work placement focused on new web design. You’ll be responsible for improving the online presence of the business, gathering requirements from multiple stakeholders, then delivering designs which fulfil internal needs as well as customer requirements. Working alongside the tech side of the business you’ll have the chance to hone your skills and learn more about working in web design in a growing business whilst adding real value.\"},\"association\":{\"host\":{\"uuid\":\"51464079-921b-4d41-9a65-95f1bed758bf\",\"full_name\":\"Keith Staines\",\"names\":[\"Keith Staines\"],\"emails\":[\"keith27staines+new@icloud.com\",\"keith.staines@workfinder.com\",\"keith27staines@icloud.com\"],\"user\":\"0c622e68-6d8b-427c-929a-ca58ff102a4b\",\"photo\":\"https://api-workfinder-com-develop.s3.amazonaws.com/media/hosts/derived/51464079-921b-4d41-9a65-95f1bed758bf.jpg\",\"phone\":\"07757262284\",\"instagram_handle\":\"\",\"twitter_handle\":\"\",\"linkedin_url\":\"https://linkedin.com/in/keith-s-42b5a8148\",\"description\":\"Originally I trained as a physicist and then worked in nuclear power stations and on space programmes for ESA and NASA. I moved into software development  in 1996. My ideal job would combine physics, mathematics and coding, and that's pretty much what I have been doing for the last few years.\",\"associations\":[\"48551e61-dd13-40dc-a517-d0b77f295412\",\"065845d2-3f9c-412f-b8f3-9374f17e5057\"],\"opted_into_marketing\":false},\"location\":{\"uuid\":\"e90cd333-ad27-456e-a2da-258f3f2bce18\",\"address_unit\":\"\",\"address_building\":\"\",\"address_street\":\"1000 Hello X Music Llp 27 Old Gloucester Street\",\"address_city\":\"London\",\"address_region\":\"Greater London\",\"address_country\":\"GB\",\"address_postcode\":\"WC1N3AX\",\"company\":{\"uuid\":\"a429fb52-84e0-4f01-aca5-f6b21e5b049d\",\"logo\":null,\"name\":\"Workfinder Limited\"}},\"title\":\"iOS Developer at Workfinder LTD\"},\"is_paid\":true,\"is_remote\":true,\"duration\":\"\"}}"
        
        recommendationItemData = recommendationItemString.data(using: .utf8)
    }
    
    func test_decode_recommendation() throws {
        let sut = try JSONDecoder().decode(RecommendationsListItem.self, from: recommendationItemData)
        XCTAssertEqual(sut.uuid, "d76e8806-c299-4c4a-98c7-b5a5a71d86be")
        XCTAssertEqual(sut.association?.host?.fullName, "Keith Staines")
        XCTAssertNotNil(sut.association?.title)
        XCTAssertEqual(sut.association?.location?.company?.name, "Workfinder Limited")
        XCTAssertNil(sut.association?.location?.company?.logo)
    }

}
