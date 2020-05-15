import WorkfinderCommon

public protocol WorkfinderViewControllerProtocol: AnyObject {
    var messageHandler: UserMessageHandler { get }
    func refreshFromPresenter()
}
