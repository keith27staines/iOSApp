
import Foundation
import WorkfinderCommon
import WorkfinderUI

protocol RegisterUserPresenterProtocol: class {
    var fullname: String? { get set }
    var nickname: String? { get set }
    var email: String? { get set }
    var password: String? { get set }
    var fullnameValidator: (String) ->  UnderlineView.State { get }
    var nicknameValidator: (String) -> UnderlineView.State { get }
    var passwordValidator: (String) -> UnderlineView.State { get }
    var emailValidator: (String) -> UnderlineView.State { get }
    var isRegisterButtonEnabled: Bool { get }
    func onDidTapRegister(onFailure: @escaping ((Error) -> Void))
}

class RegisterUserPresenter: RegisterUserPresenterProtocol {
    let userRepository: UserRepositoryProtocol
    let service: RegisterUserServiceProtocol
    var user: User
    
    static func validateCharacterCount(string: String, min: Int, max: Int) -> UnderlineView.State {
        switch string.trimmingCharacters(in: .whitespaces).count {
        case 0: return .empty
        case let x where x < min: return .bad
        case let x where x > max: return .bad
        default: return .good
        }
    }
    
    let fullnameValidator: (String) -> UnderlineView.State = { string in
        return RegisterUserPresenter.validateCharacterCount(string: string, min: 3, max: 250)
    }
    
    let nicknameValidator: (String) -> UnderlineView.State = { string in
        return RegisterUserPresenter.validateCharacterCount(string: string, min: 3, max: 250)
    }
    
    let passwordValidator: (String) -> UnderlineView.State = { string in
        return RegisterUserPresenter.validateCharacterCount(string: string, min: 8, max: 250)
    }
    
    let emailValidator: (String) -> UnderlineView.State = { string in
        let trimmed = string.trimmingCharacters(in: .whitespaces)
        guard trimmed.count > 0 else { return .empty }
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let isValid = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: string)
        return isValid ? .good : .bad
    }
    
    var fullname: String? {
        get { user.fullname }
        set { user.fullname = newValue }
    }
    var nickname: String? {
        get { user.nickname }
        set { user.nickname = newValue }
    }
    var password: String?  {
        get { user.password }
        set { user.password = newValue }
    }
    var email: String? {
        get { user.email }
        set { user.email = newValue }
    }
    
    var isRegisterButtonEnabled: Bool {
        let isValid = UnderlineView.State.good
        return
            isValid == fullnameValidator(fullname ?? "") &&
            isValid == nicknameValidator(nickname ?? "") &&
            isValid == emailValidator(email ?? "") &&
            isValid == passwordValidator(password ?? "")
    }
    
    func onDidTapRegister(onFailure: @escaping ((Error) -> Void)) {
        service.registerUser(user: user) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.userRepository.saveAccessToken(token.key)
                self.coordinator?.onDidRegister(user: self.user)
            case .failure(let error):
                onFailure(error)
            }
        }
    }
    var coordinator: RegisterAndSignInCoordinatorProtocol?
    init(coordinator: RegisterAndSignInCoordinatorProtocol, userRepository: UserRepositoryProtocol, service: RegisterUserServiceProtocol) {
        self.coordinator = coordinator
        self.userRepository = userRepository
        self.service = service
        self.user = userRepository.loadUser()
    }
    
    func saveCredentials() {
        userRepository.save(user: user)
    }
}
