import Foundation
import WorkfinderCommon

public protocol CreateCandidateServiceProtocol {
    func createCandidate(candidate: CreatableCandidate, completion: @escaping ((Result<Candidate, Error>) -> Void))
}

public protocol FetchCandidateServiceProtocol {
    func fetchCandidate(uuid: F4SUUID, completion: @escaping ((Result<Candidate, Error>) -> Void))
}

public protocol UpdateCandidateServiceProtocol {
    func update(candidate: Candidate, completion: @escaping ((Result<Candidate, Error>) -> Void))
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
    
    public func update(candidate: Candidate, completion: @escaping ((Result<Candidate, Error>) -> Void)) {
        do {
            let relativePath = "candidates/"
            let request = try buildRequest(relativePath: relativePath, verb: .patch, body: candidate)
            performTask(with: request, completion: completion, attempting: #function)
        } catch {
            completion(Result<Candidate,Error>.failure(error))
        }
    }
}
