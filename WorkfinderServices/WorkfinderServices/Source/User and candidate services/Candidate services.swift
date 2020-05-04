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

public class CreateCandidateService: WorkfinderService, CreateCandidateServiceProtocol {
    
    public func createCandidate(candidate: Candidate, userUuid: F4SUUID, completion: @escaping ((Result<Candidate, Error>) -> Void)) {
        
        do {
            let relativePath = "candidates/"
            let jsonBody = [
                "date_of_birth": candidate.dateOfBirth,
                "current_level_of_study": candidate.currentLevelOfStudy,
                "placement_type": candidate.placementType,
                "user": userUuid
            ]
            let request = try buildRequest(relativePath: relativePath, verb: .post, body: jsonBody)
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
