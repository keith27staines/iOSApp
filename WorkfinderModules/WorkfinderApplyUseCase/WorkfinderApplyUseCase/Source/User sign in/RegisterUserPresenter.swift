
import WorkfinderCommon
import WorkfinderUI

class RegisterUserPresenter: RegisterAndSignInUserBasePresenter {
    
    init(coordinator: RegisterAndSignInCoordinatorProtocol, userRepository: UserRepositoryProtocol, registerUserLogic: RegisterUserLogicProtocol) {
        super.init(coordinator: coordinator, userRepository: userRepository, registerUserLogic: registerUserLogic, mode: .register)
    }
    
    override var isPrimaryButtonEnabled: Bool {
        let isValid = UnderlineView.State.good
        if self.isGuardianEmailRequired {
            return self.isTermsAndConditionsAgreed &&
                isValid == fullnameValidityState &&
                isValid == emailValidityState &&
                isValid == guardianValidityState &&
                isValid == passwordValidityState &&
                isValid == phoneValidityState
        }
        return self.isTermsAndConditionsAgreed &&
            isValid == fullnameValidityState &&
            isValid == emailValidityState &&
            isValid == passwordValidityState &&
            isValid == phoneValidityState
    }
}
