
import Foundation
import WorkfinderCommon

protocol UserSigninPresenterProtocol {
    var fullname: String? { get }
    var nickname: String? { get }
    var password: String? { get }
}

class UserSigninPresenter: UserSigninPresenterProtocol {
    
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
    
    let userRepository: UserRepositoryProtocol
    var user: User
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
        self.user = userRepository.loadUser()
    }
    
    func saveCredentials() {
        userRepository.save(user: user)
    }
}
