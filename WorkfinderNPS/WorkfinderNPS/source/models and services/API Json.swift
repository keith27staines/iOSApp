//
//  API Json.swift
//  WorkfinderNPS
//
//  Created by Keith Staines on 27/04/2021.
//

import Foundation
import WorkfinderCommon

// MARK:= GET /v3/reviews/reasons
struct ReasonJson: Decodable {
    var id: Int
    var candidateReviewingHost: Bool
    var text: String
    var scoreRange: ScoreRangeJson
    
    private enum CodingKeys: String, CodingKey {
        case id
        case candidateReviewingHost = "candidate_reviewing_host"
        case text
        case scoreRange = "score_range"
    }
    
    struct ScoreRangeJson: Decodable {
        var lower: Int
        var upper: Int
    }
}


// MARK:- PATCH /v3/reviews/<uuid>
struct PatchReviewJson: Codable {
    var anonymous: Bool = false
    var feedback: String = ""
    var otherReason: String = ""
    var reasons: [Int] = []
    var score: Int = 0
    
    private enum CodingKeys: String, CodingKey {
        case otherReason = "other_reason"
    }
}


// MARK:- GET /v3/reviews/<uuid>
struct GetReviewJson: Decodable {
    var uuid: F4SUUID
    var hostReviewingCandidate: Bool
    var anonymous: Bool
    var feedback: String
    var otherReason: String
    var reasons: [Int]
    var score: Int
    var placement: Placement
    
    struct Placement: Decodable {
        
        var hostFullname: String { association.host.user.fullName }
        var candidateFullName: String { candidate.user.fullName }
        var companyName: String { association.location.company.name }
        var projectName: String { "unknown project" }
        var candidate: Person
        var association: Asssociation
        
        struct Person: Decodable {
            var user: User
            
            struct User: Decodable {
                var fullName: String
                private enum CodingKeys: String, CodingKey {
                    case fullName = "full_name"
                }
            }
        }
        
        struct Asssociation: Decodable {
            var host: Person
            var location: Location
            
            struct Location: Decodable {
                var company: Company
                struct Company: Decodable {
                    var name: String
                }
            }
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case hostReviewingCandidate = "host_reviewing_candidate"
        case anonymous
        case feedback
        case otherReason = "other_reason"
        case reasons
        case score
        case placement
    }
    
}
