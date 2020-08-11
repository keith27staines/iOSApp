
import WorkfinderCommon

public protocol ErrorHandlerProviderProtocol {
    var errorHandler: ErrorHandlerProtocol { get }
}

public protocol ErrorHandlerProtocol: AnyObject {
    func startHandleError(
        _ error: Error?,
        presentingViewController: UIViewController,
        messageHandler: UserMessageHandler,
        cancel: @escaping (() -> Void),
        retry: @escaping (()->Void))
}
