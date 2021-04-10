//
//  BaseAccountPresenter.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 10/04/2021.
//

import Foundation
import WorkfinderCommon
import WorkfinderServices
import UIKit

class BaseAccountPresenter: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var candidateRepository: UserRepositoryProtocol = UserRepository()
    weak var coordinator: AccountCoordinator?
    var service: AccountServiceProtocol
    
    var candidate: Candidate {
        get { candidateRepository.loadCandidate() }
        set { candidateRepository.saveCandidate(newValue) }
    }
    
    var user: User {
        get { candidateRepository.loadUser() }
        set { candidateRepository.saveUser(newValue)}
    }
    
    func reloadPresenter(completion: @escaping (Error?) -> Void) {
        let repo = UserRepository()
        guard repo.isCandidateLoggedIn else { return }
        service.getAccount { (result) in
            switch result {
            case .success(let account):
                repo.saveUser(account.user)
                repo.saveCandidate(account.candidate)
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    init(coordinator: AccountCoordinator, accountService: AccountServiceProtocol) {
        self.coordinator = coordinator
        self.service = accountService
        super.init()
    }
}

