
import WorkfinderCommon
import WorkfinderUI

class RegisterUserPresenter: RegisterAndSignInUserBasePresenter {
    
    init(coordinator: RegisterAndSignInCoordinatorProtocol, userRepository: UserRepositoryProtocol, registerUserLogic: RegisterUserLogicProtocol) {
        super.init(coordinator: coordinator, userRepository: userRepository, registerUserLogic: registerUserLogic, mode: .register)
    }
    
    override var isPrimaryButtonEnabled: Bool {
        let isValid = UnderlineView.State.good

        return self.isTermsAndConditionsAgreed &&
            isValid == firstnameValidityState &&
            isValid == lastnameValidityState &&
            isValid == emailValidityState &&
            isValid == passwordValidityState &&
            isValid == password2ValidityState
    }
}
