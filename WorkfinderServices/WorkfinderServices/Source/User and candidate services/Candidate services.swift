import Foundation
import WorkfinderCommon

public protocol CreateCandidateServiceProtocol {
    func createCandidate(candidate: CreatableCandidate, completion: @escaping ((Result<Candidate, Error>) -> Void))
}

public protocol FetchCandidateServiceProtocol {
    func fetchCandidate(uuid: F4SUUID, completion: @escaping ((Result<Candidate, Error>) -> Void))
}

public protocol UpdateCandidateServiceProtocol {
    func updateDOB(candidateUuid: F4SUUID, dobString: String, completion: @escaping ((Result<Candidate, Error>) -> Void))
    
    func updatePostcode(candidateUuid: F4SUUID, postcode: String, completion: @escaping ((Result<Candidate, Error>) -> Void))
}

public class CreateCandidateService: WorkfinderService, CreateCandidateServiceProtocol {
    
    public func createCandidate(candidate: CreatableCandidate, completion: @escaping ((Result<Candidate, Error>) -> Void)) {
        
        do {
            let relativePath = "candidates/"
            let request = try buildRequest(relativePath: relativePath, verb: .post, body: candidate)
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

public class UpdateCandidateService: WorkfinderService, UpdateCandidateServiceProtocol {
    
    public func updateDOB(candidateUuid: F4SUUID, dobString: String, completion: @escaping ((Result<Candidate, Error>) -> Void)) {
        struct DOB: Codable {
            var date_of_birth: String
        }
        let dob = DOB(date_of_birth: dobString)
        do {
            let relativePath = "candidates/\(candidateUuid)/"
            let request = try buildRequest(relativePath: relativePath, verb: .patch, body: dob)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(Result<Candidate,Error>.failure(error))
        }
    }
    
    public func updatePostcode(candidateUuid: F4SUUID, postcode: String, completion: @escaping ((Result<Candidate, Error>) -> Void)) {
        struct Postcode: Codable {
            var postcode: String
            init(_ postcode: String) {
                self.postcode = postcode
            }
        }
        do {
            let relativePath = "candidates/\(candidateUuid)/"
            let request = try buildRequest(relativePath: relativePath, verb: .patch, body: Postcode(postcode))
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(Result<Candidate,Error>.failure(error))
        }
    }
}
