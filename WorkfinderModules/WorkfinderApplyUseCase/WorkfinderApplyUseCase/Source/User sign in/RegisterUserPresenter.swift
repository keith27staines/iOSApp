
import Foundation
import WorkfinderCommon
import WorkfinderUI

import WorkfinderServices

protocol RegisterAndSignInPresenterProtocol: class {
    var fullname: String? { get set }
    var nickname: String? { get set }
    var email: String? { get set }
    var password: String? { get set }
    var phone: String? { get set }
    var fullnameValidityState: UnderlineView.State { get }
    var emailValidityState: UnderlineView.State { get }
    var passwordValidityState: UnderlineView.State { get }
    var phoneValidityState: UnderlineView.State { get }
    var nicknameValidityState: UnderlineView.State { get }

    var isPrimaryButtonEnabled: Bool { get }
    func onDidTapPrimaryButton(onFailure: @escaping ((Error) -> Void))
    func onDidTapSwitchMode()
    func onViewDidLoad(_ view: RegisterAndSignInBaseViewController)
    var isTermsAndConditionsAgreed: Bool { get set }
}

class RegisterAndSignInUserBasePresenter: RegisterAndSignInPresenterProtocol {
    
    let userRepository: UserRepositoryProtocol
    let registerLogic: RegisterUserLogicProtocol
    let mode: RegisterAndSignInMode
    var user: User
    var coordinator: RegisterAndSignInCoordinatorProtocol?
    weak var view: RegisterAndSignInBaseViewController?
    
    var isPrimaryButtonEnabled: Bool {
        return false
    }
    
    init(coordinator: RegisterAndSignInCoordinatorProtocol,
         userRepository: UserRepositoryProtocol,
         registerUserLogic: RegisterUserLogicProtocol,
         mode: RegisterAndSignInMode) {
        self.coordinator = coordinator
        self.userRepository = userRepository
        self.registerLogic = registerUserLogic
        self.mode = mode
        self.user = userRepository.loadUser()
    }
    
    func onViewDidLoad(_ view: RegisterAndSignInBaseViewController) { self.view = view }
    
    func onDidTapPrimaryButton(onFailure: @escaping ((Error) -> Void)) {
        userRepository.save(user: user)
        registerLogic.start { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.coordinator?.onUserRegisteredAndCandidateCreated(pop: true)
            case .failure(let error):
                onFailure(error)
            }
        }
    }
    
    func onDidTapSwitchMode() {
        let newMode: RegisterAndSignInMode = (mode == .register) ? .signIn : .register
        coordinator?.switchMode(newMode)
    }

    var email: String? {
        get { user.email }
        set { user.email = newValue }
    }
    
    var fullname: String? {
        get { user.fullname }
        set { user.fullname = newValue }
    }
    
    var password: String?  {
        get { user.password }
        set { user.password = newValue }
    }
    
    var phone: String?
        
    var nickname: String? {
        get { user.nickname }
        set { user.nickname = newValue }
    }
    
    var emailValidityState: UnderlineView.State {
        return _emailValidator(email ?? "")
    }
    
    var passwordValidityState: UnderlineView.State {
        return _passwordValidator(password ?? "")
    }
      
    var fullnameValidityState: UnderlineView.State {
        return _fullnameValidator(fullname ?? "")
    }
    
    var phoneValidityState: UnderlineView.State {
        return _phoneValidator(phone ?? "")
    }
    
    var nicknameValidityState: UnderlineView.State {
        return _nicknameValidator(nickname ?? "")
    }

    var isTermsAndConditionsAgreed: Bool = false
    
    let _passwordValidator: (String) -> UnderlineView.State = { password in
        guard !password.isEmpty else { return .empty }
        let alphabet = "abcdefghijklmnopqrstuvwxyz"
        let alphabetSet = CharacterSet(charactersIn: alphabet)
        let numbersSet = CharacterSet(charactersIn: "0123456789")
        let upperAlphabetSet = CharacterSet(charactersIn: alphabet.uppercased())
        let passwordSet = CharacterSet(charactersIn: password)
        guard
            !alphabetSet.intersection(passwordSet).isEmpty &&
            !upperAlphabetSet.intersection(passwordSet).isEmpty &&
            !numbersSet.intersection(passwordSet).isEmpty
            else { return UnderlineView.State.bad }
        return RegisterAndSignInUserBasePresenter.validateCharacterCount(string: password, min: 8, max: 20)
    }
    
    let _emailValidator: (String) -> UnderlineView.State = { string in
        let trimmed = string.trimmingCharacters(in: .whitespaces)
        guard trimmed.count > 0 else { return .empty }
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let isValid = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: string)
        return isValid ? .good : .bad
    }
    
    let _fullnameValidator: (String) -> UnderlineView.State = { string in
        return RegisterUserPresenter.validateCharacterCount(string: string, min: 3, max: 250)
    }
    
    let _nicknameValidator: (String) -> UnderlineView.State = { string in
        return RegisterUserPresenter.validateCharacterCount(string: string, min: 3, max: 250)
    }
    
    let _phoneValidator: (String) -> UnderlineView.State = { string in
        let numbersSet = CharacterSet(charactersIn: "0123456789")
        guard numbersSet.isSuperset(of: CharacterSet(charactersIn: string))
            else { return .bad }
        return RegisterUserPresenter.validateCharacterCount(string: string, min: 11, max: 11)
    }
    
    static func validateCharacterCount(string: String, min: Int, max: Int) -> UnderlineView.State {
        switch string.trimmingCharacters(in: .whitespaces).count {
        case 0: return .empty
        case let x where x < min: return .bad
        case let x where x > max: return .bad
        default: return .good
        }
    }
}

class SignInUserPresenter: RegisterAndSignInUserBasePresenter {
    
    init(coordinator: RegisterAndSignInCoordinatorProtocol, userRepository: UserRepositoryProtocol, registerUserLogic: RegisterUserLogicProtocol) {
        super.init(coordinator: coordinator, userRepository: userRepository, registerUserLogic: registerUserLogic, mode: .signIn)
    }
    
    override var isPrimaryButtonEnabled: Bool {
        let isValid = UnderlineView.State.good
        return
            isValid == emailValidityState &&
            isValid == passwordValidityState
    }
}

class RegisterUserPresenter: RegisterAndSignInUserBasePresenter {
    
    init(coordinator: RegisterAndSignInCoordinatorProtocol, userRepository: UserRepositoryProtocol, registerUserLogic: RegisterUserLogicProtocol) {
        super.init(coordinator: coordinator, userRepository: userRepository, registerUserLogic: registerUserLogic, mode: .register)
    }
    
    override var isPrimaryButtonEnabled: Bool {
        let isValid = UnderlineView.State.good
        return self.isTermsAndConditionsAgreed &&
            isValid == fullnameValidityState &&
            isValid == emailValidityState &&
            isValid == passwordValidityState &&
            isValid == phoneValidityState
    }
    
}
