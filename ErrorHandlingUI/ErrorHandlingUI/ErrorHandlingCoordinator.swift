


import WorkfinderCommon
import WorkfinderUI
import WorkfinderCoordinators
import WorkfinderRegisterCandidate

public class ErrorHandler: ErrorHandlerProtocol {
    
    public init() {}
    
    public func handle(
        _ error: Error?,
        userRepository: UserRepositoryProtocol,
        messageHandler: UserMessageHandler,
        cancel: @escaping (() -> Void),
        retry: @escaping (() -> Void)) {
        messageHandler.hideLoadingOverlay()
        guard let error = error else { return }
        guard let workfinderError = error as? WorkfinderError, workfinderError.code == 401 else {
            messageHandler.displayOptionalErrorIfNotNil(error, cancelHandler: cancel, retryHandler: retry)
            return
        }
    }
}
