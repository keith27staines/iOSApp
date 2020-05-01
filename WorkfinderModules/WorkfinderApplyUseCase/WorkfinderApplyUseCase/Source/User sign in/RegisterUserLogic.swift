
import Foundation
import WorkfinderCommon
import WorkfinderServices

protocol RegisterUserLogicProtocol: class {
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
         mode: RegisterAndSignInMode) {
        self.networkConfig = networkConfig
        self.userRepository = userRepository
        self.mode = mode
    }
    
    var completion: ((Result<Candidate,Error>) -> Void)?
    
    func start(completion: @escaping ((Result<Candidate,Error>) -> Void)) {
        self.completion = completion
        switch mode {
        case .register:
            registerIfNecessary()
        case .signIn:
            signInIfNecessary()
        }
    }
    
    func signInIfNecessary() {
        let user = userRepository.loadUser()
        signInService.signIn(user: user) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.onIsRegistered(tokenValue: token)
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
            case .failure(let error):
                self.completion?(Result<Candidate,Error>.failure(error))
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
        userRepository.save(user: user)
        let userUuid = user.uuid!
        createCandidateIfNecessary(userUuid: userUuid)
    }
    
    func createCandidateIfNecessary(userUuid: F4SUUID) {
        var candidate = userRepository.loadCandidate()
        if let _ = candidate.uuid {
            fetchCandidateFromServer()
            return
        }
        candidate.placementType = "internship"
        candidate.currentLevelOfStudy = "undergraduate"
        userRepository.save(candidate: candidate)
        createCandidateService.createCandidate(candidate: candidate, userUuid: userUuid) {
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
    
    func fetchCandidateFromServer() {
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
        isCandidateCreated = true
        isCandidateFetched = true
        userRepository.save(candidate: candidate)
        completion?(Result<Candidate,Error>.success(candidate))
    }
    
}
