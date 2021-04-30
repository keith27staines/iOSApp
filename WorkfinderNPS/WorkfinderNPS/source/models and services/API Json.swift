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
public struct PatchReviewJson: Codable {
    public var anonymous: Bool = false
    public var feedbackText: String = ""
    public var otherReasonText: String = ""
    public var reasons: [Int] = []
    public var score: Int = 0
    
    private enum CodingKeys: String, CodingKey {
        case anonymous
        case reasons
        case score
        case feedbackText = "feedback"
        case otherReasonText = "other_reason"
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
    var score: Int?
    var placement: Placement
    
    struct Placement: Decodable {
        
        var hostFullname: String? { association?.host.user.fullName }
        var candidateFullName: String? { candidate?.user.fullName }
        var companyName: String? { association?.location.company.name }
        var projectName: String? { associatedProject?.name }
        var candidate: Person?
        var associatedProject: Project?
        var association: Association?
        
        struct Project: Decodable {
            var name: String?
        }
        
        struct Person: Decodable {
            var user: User
            
            struct User: Decodable {
                var fullName: String
                private enum CodingKeys: String, CodingKey {
                    case fullName = "full_name"
                }
            }
        }
        
        struct Association: Decodable {
            var host: Person
            var location: Location
            
            struct Location: Decodable {
                var company: Company
                struct Company: Decodable {
                    var name: String
                }
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case candidate
            case association
            case associatedProject = "associated_project"
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
