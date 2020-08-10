
import WorkfinderCommon
import WorkfinderUI
import WorkfinderCoordinators


public protocol ErrorHandlerProtocol: AnyObject {
    func handle(_ error: Error?,
                messageHandler: UserMessageHandler,
                cancel: @escaping (() -> Void),
                retry: @escaping (()->Void))
}

public class ErrorHandler: ErrorHandlerProtocol {
    public func handle(_ error: Error?,
                messageHandler: UserMessageHandler,
                cancel: @escaping (() -> Void),
                retry: @escaping (()->Void)) {
        messageHandler.hideLoadingOverlay()
        guard let error = error else { return }
        guard let workfinderError = error as? WorkfinderError, workfinderError.code == 401 else {
            messageHandler.displayOptionalErrorIfNotNil(error, cancelHandler: cancel, retryHandler: retry)
            return
        }
        let repo = UserRepository()
        let user = repo.loadUser()
        if let email = user.email, let password = user.password  {
            // login with credentials
        } else {
            //
        }
        
    }
}
