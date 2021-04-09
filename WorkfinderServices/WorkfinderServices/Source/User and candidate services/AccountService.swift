//
//  AccountService.swift
//  WorkfinderServices
//
//  Created by Keith Staines on 09/04/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import Foundation
import WorkfinderCommon

public protocol AccountServiceProtocol {
    func getAccount(completion: @escaping (Result<Account,Error>) -> Void)
}

public class AccountService: WorkfinderService, AccountServiceProtocol {
    
    let userService: FetchMeService
    let candidateService: FetchCandidateService
    
    public override init(networkConfig: NetworkConfig) {
        userService = FetchMeService(networkConfig: networkConfig)
        candidateService = FetchCandidateService(networkConfig: networkConfig)
        super.init(networkConfig: networkConfig)
    }
    
    
    private func getUser(completion: @escaping (Result<User,Error>) -> Void) {
        userService.fetch { (result) in
            completion(result)
        }
    }
    
    private func getCandidate(uuid: F4SUUID, completion: @escaping (Result<Candidate,Error>) -> Void) {
        candidateService.fetchCandidate(uuid: uuid) { (result) in
            completion(result)
        }
    }
    
    public func getAccount(completion: @escaping (Result<Account,Error>) -> Void) {
    
        getUser { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                guard let candidateUuid = user.candidateUuid else {
                    completion(.failure(WorkfinderError.init(errorType: .badParameters, attempting: "getAccount")))
                    return
                }
                self.getCandidate(uuid: candidateUuid) { (result) in
                    switch result {
                    case .success(let candidate):
                        completion(.success(Account(user: user, candidate: candidate)))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
