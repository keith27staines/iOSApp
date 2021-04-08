//
//  AccountPresenter.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 08/04/2021.
//

import Foundation
import WorkfinderCommon

class AccountPresenter {
    var candidateRepository: UserRepositoryProtocol = UserRepository()
    
    var candidate: Candidate {
        get { candidateRepository.loadCandidate() }
        set { candidateRepository.saveCandidate(newValue) }
    }
}
