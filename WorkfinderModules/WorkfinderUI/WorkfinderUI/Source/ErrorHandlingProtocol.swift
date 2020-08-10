
import WorkfinderCommon

public protocol ErrorHandlerProtocol: AnyObject {
    func handle(_ error: Error?,
                userRepository: UserRepositoryProtocol,
                messageHandler: UserMessageHandler,
                cancel: @escaping (() -> Void),
                retry: @escaping (()->Void))
}
