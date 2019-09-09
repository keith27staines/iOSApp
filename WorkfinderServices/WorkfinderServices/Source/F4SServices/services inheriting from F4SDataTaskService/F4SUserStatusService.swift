import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public extension Notification.Name {
    static let f4sUserStatusUpdated = Notification.Name(
        rawValue: "f4sUserStatusUpdated")
}

public class F4SUserStatusService : F4SDataTaskService {
    
    public static let shared: F4SUserStatusService = F4SUserStatusService()
    
    public var userStatus: F4SUserStatus?
    
    public init() {
        let apiName = "user/status"
        super.init(baseURLString: NetworkConfig.workfinderApiV2, apiName: apiName)
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
}

// MARK:- F4SDocumentServiceProtocol conformance
extension F4SUserStatusService : F4SUserStatusServiceProtocol {
    public func getUserStatus(completion: @escaping (F4SNetworkResult<F4SUserStatus>) -> ()) {
        beginGetRequest(attempting: "Get status for current user", completion: completion)
    }
}
