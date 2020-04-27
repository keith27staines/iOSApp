
import Foundation
import WorkfinderCommon
import WorkfinderServices

protocol RegisterUserLogicProtocol: class {
    func start(completion: @escaping ((Result<Candidate,Error>) -> Void))
}

class RegisterUserLogic: RegisterUserLogicProtocol {
    
    let user: User
    let userStore: UserRepositoryProtocol
    let networkConfig: NetworkConfig
    
    lazy var registerService: RegisterUserServiceProtocol = {
        return RegisterUserService(networkConfig: self.networkConfig)
    }()
    
    lazy var fetchMeService: FetchMeService = {
        return FetchMeService(networkConfig: self.networkConfig)
    }()
    
    lazy var createCandidateService: CreateCandidateServiceProtocol = {
        CreateCandidateService(networkConfig: self.networkConfig)
    }()
    
    lazy var fetchCandidateService: FetchCandidateServiceProtocol = {
        FetchCandidateService(networkConfig: self.networkConfig)
    }()
    
    init(networkConfig: NetworkConfig,
         userStore: UserRepositoryProtocol) {
        self.networkConfig = networkConfig
        self.userStore = userStore
        self.user = userStore.loadUser()
    }
    
    var completion: ((Result<Candidate,Error>) -> Void)?
    
    func start(completion: @escaping ((Result<Candidate,Error>) -> Void)) {
        self.completion = completion
        registerIfNecessary()
    }
    
    func registerIfNecessary() {
        if let token = userStore.loadAccessToken() {
            onIsRegistered(tokenValue: token)
            return
        }
        registerService.registerUser(user: user) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.userStore.saveAccessToken(token.key)
                self.onIsRegistered(tokenValue: token.key)
            case .failure(let error):
                self.completion?(Result<Candidate,Error>.failure(error))
            }
        }
    }
    
    func onIsRegistered(tokenValue: String) {
        fetchUserIfNecessary()
    }
    
    func fetchUserIfNecessary() {
        let user = userStore.loadUser()
        if user.uuid != nil {
            onUserFetched(user: user)
            return
        }
        fetchMeService.fetch { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.onUserFetched(user: user)
            case .failure(let error):
                self.completion?(Result<Candidate,Error>.failure(error))
            }
        }
    }
    
    func onUserFetched(user: User) {
        userStore.save(user: user)
        let userUuid = user.uuid!
        createCandidateIfNecessary(userUuid: userUuid)
    }
    
    func createCandidateIfNecessary(userUuid: F4SUUID) {
        let candidate = userStore.loadCandidate()
        if let _ = candidate.uuid {
            fetchCandidate()
            return
        }
        createCandidateService.createCandidate(userUuid: userUuid) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let candidate):
                self.onCandidateFetched(candidate: candidate)
            case .failure(let error):
                self.completion?(Result<Candidate,Error>.failure(error))
            }
        }
    }
    
    func fetchCandidate() {
        fetchCandidateService.fetchCandidate { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let candidate):
                self.onCandidateFetched(candidate: candidate)
            case .failure(let error):
                self.completion?(Result<Candidate,Error>.failure(error))
            }
        }
    }
    
    func onCandidateFetched(candidate: Candidate) {
        userStore.save(candidate: candidate)
        completion?(Result<Candidate,Error>.success(candidate))
    }
    
}
