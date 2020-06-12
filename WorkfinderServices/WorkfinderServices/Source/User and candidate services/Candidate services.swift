import Foundation
import WorkfinderCommon

public protocol CreateCandidateServiceProtocol {
    func createCandidate(candidate: Candidate, userUuid: F4SUUID, completion: @escaping ((Result<Candidate, Error>) -> Void))
}

public protocol FetchCandidateServiceProtocol {
    func fetchCandidate(uuid: F4SUUID, completion: @escaping ((Result<Candidate, Error>) -> Void))
}

public protocol UpdateCandidateServiceProtocol {
    func update(candidate: Candidate, completion: @escaping ((Result<Candidate, Error>) -> Void))
}

struct CreatableCandidate: Codable {
    var date_of_birth: String?
    var guardian_email: String?
    var user: F4SUUID
    var phone: String?
    var has_allowed_sharing_with_educational_institution: Bool?
    var has_allowed_sharing_with_employers: Bool?
    
    init(candidate: Candidate, userUuid: F4SUUID) {
        user = userUuid
        date_of_birth = candidate.dateOfBirth
        guardian_email = candidate.guardianEmail
        phone = candidate.phone
        has_allowed_sharing_with_employers = candidate.allowedSharingWithEmployers
        has_allowed_sharing_with_educational_institution = candidate.allowedSharingWithEducationInstitution
    }
}

public class CreateCandidateService: WorkfinderService, CreateCandidateServiceProtocol {
    
    public func createCandidate(candidate: Candidate, userUuid: F4SUUID, completion: @escaping ((Result<Candidate, Error>) -> Void)) {
        
        do {
            let relativePath = "candidates/"
            let creatableCandidate = CreatableCandidate(candidate: candidate, userUuid: userUuid)
            let request = try buildRequest(relativePath: relativePath, verb: .post, body: creatableCandidate)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(Result<Candidate,Error>.failure(error))
        }
    }
}

public class FetchCandidateService: WorkfinderService, FetchCandidateServiceProtocol {
    
    public func fetchCandidate(uuid: F4SUUID, completion: @escaping ((Result<Candidate, Error>) -> Void)) {
        
        do {
            let relativePath = "candidates/\(uuid)/"
            let request = try buildRequest(relativePath: relativePath, queryItems: nil, verb: .get)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(Result<Candidate,Error>.failure(error))
        }
    }
}

public class UpdateCandidateService: WorkfinderService {
    
    public func update(candidate: Candidate, completion: @escaping ((Result<Candidate, Error>) -> Void)) {
        do {
            let relativePath = "candidate/"
            let request = try buildRequest(relativePath: relativePath, verb: .patch, body: candidate)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(Result<Candidate,Error>.failure(error))
        }
    }
}
