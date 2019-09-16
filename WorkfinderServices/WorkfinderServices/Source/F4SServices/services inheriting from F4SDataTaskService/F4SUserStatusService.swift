import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public extension Notification.Name {
    static let f4sUserStatusUpdated = Notification.Name(
        rawValue: "f4sUserStatusUpdated")
}

public class F4SUserStatusService : F4SDataTaskService, F4SUserStatusServiceProtocol {
    
    public var userStatus: F4SUserStatus?
    
    public init(configuration: NetworkConfig) {
        let apiName = "user/status"
        super.init(baseURLString: configuration.workfinderApiV2,
                   apiName: apiName,
                   configuration: configuration)
    }
    
    public func beginStatusUpdate() {
        getUserStatus { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .error(_):
                    break
                case .success(let status):
                    self?.userStatus = status
                    let badgeNumber = status.unreadMessageCount
                    UIApplication.shared.applicationIconBadgeNumber = max(badgeNumber,0)
                    NotificationCenter.default.post(name: .f4sUserStatusUpdated, object: status)
                }
            }
        }
    }

    public func getUserStatus(completion: @escaping (F4SNetworkResult<F4SUserStatus>) -> ()) {
        beginGetRequest(attempting: "Get status for current user", completion: completion)
    }
}
