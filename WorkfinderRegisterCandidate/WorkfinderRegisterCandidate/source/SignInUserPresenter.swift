
import WorkfinderCommon
import WorkfinderUI

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
    
    override var passwordValidityState: UnderlineView.State {
        switch password?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0 {
        case 0: return .empty
        default: return .good
        }
    }
}
