
import Foundation
import WorkfinderCommon
import WorkfinderServices

protocol RegisterUserLogicProtocol: AnyObject {
    func start(completion: @escaping ((Result<Candidate,Error>) -> Void))
}

class RegisterUserLogic: RegisterUserLogicProtocol {
    
    let userRepository: UserRepositoryProtocol
    let networkConfig: NetworkConfig
    let mode: RegisterAndSignInMode
    
    var isRegistered: Bool = false
    var isUserUuidFetched:  Bool = false
    var isCandidateCreated: Bool = false
    var isCandidateFetched: Bool = false
    let log: F4SAnalytics
    
    lazy var registerService: RegisterUserServiceProtocol = {
        return RegisterUserService(networkConfig: self.networkConfig)
    }()
    
    lazy var signInService: SignInUserServiceProtocol = {
        return SignInUserService(networkConfig: self.networkConfig)
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
         userRepository: UserRepositoryProtocol,
         mode: RegisterAndSignInMode,
         log: F4SAnalytics) {
        self.networkConfig = networkConfig
        self.userRepository = userRepository
        self.mode = mode
        self.log = log
    }
    
    var completion: ((Result<Candidate,Error>) -> Void)?
    
    func start(completion: @escaping ((Result<Candidate,Error>) -> Void)) {
        self.completion = completion
        switch mode {
        case .register:
            registerIfNecessary()
        case .signIn:
            signIn()
        }
    }
    
    func signIn() {
        let user = userRepository.loadUser()
        signInService.signIn(user: user) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.onIsRegistered(tokenValue: token.key)
            case .failure(let error):
                self.completion?(Result<Candidate,Error>.failure(error))
            }
        }
    }
    
    func registerIfNecessary() {
        if let token = userRepository.loadAccessToken() {
            onIsRegistered(tokenValue: token)
            return
        }
        let user = userRepository.loadUser()
        registerService.registerUser(user: user) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.onIsRegistered(tokenValue: token.key)
            case .failure(let error): self.completion?(Result<Candidate,Error>.failure(error))
            }
        }
    }
    
    func onIsRegistered(tokenValue: String) {
        self.isRegistered = true
        self.userRepository.saveAccessToken(tokenValue)
        fetchUserIfNecessary()
    }
    
    func fetchUserIfNecessary() {
        let user = userRepository.loadUser()
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
        isUserUuidFetched = true
        userRepository.saveUser(user)
        if let candidateUuid = user.candidateUuid {
            fetchCandidateFromServer(candidateUuid: candidateUuid)
        } else {
            createCandidateIfNecessary()
        }
        
    }
    
    func fetchCandidateFromServer(candidateUuid: F4SUUID) {
        fetchCandidateService.fetchCandidate(uuid: candidateUuid) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let candidate): self.onCandidateFetched(candidate: candidate)
            case .failure(let error):
                if let error = error as? WorkfinderError {
                    switch error.code {
                    case 44: self.createCandidateIfNecessary()
                        self.completion?(Result<Candidate,Error>.failure(error))
                    default: break
                    }
                }
            }
        }
    }
    
    func onCandidateFetched(candidate: Candidate) {
        isCandidateCreated = true
        isCandidateFetched = true
        userRepository.saveCandidate(candidate)
        NotificationCenter.default.post(name: .wfDidLoginCandidate, object: nil)
        completion?(Result<Candidate,Error>.success(candidate))
    }
    
    func createCandidateIfNecessary() {
        let user = userRepository.loadUser()
        let userUuid = user.uuid!
        let candidate = userRepository.loadCandidate()
        if let candidateUuid = candidate.uuid {
            fetchCandidateFromServer(candidateUuid: candidateUuid)
            return
        }
        userRepository.saveCandidate(candidate)
        let creatableCandidate = CreatableCandidate(candidate: candidate, userUuid: userUuid)
        createCandidateService.createCandidate(candidate: creatableCandidate) {
            [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let candidate):
                self.onCandidateFetched(candidate: candidate)
            case .failure(let error):
                self.completion?(Result<Candidate,Error>.failure(error))
            }
        }
    }
}
