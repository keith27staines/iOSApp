
public protocol AllowedToApplyLogicProtocol {
    
    var draftTimelinePlacement: F4STimelinePlacement? { get set }
    var draftPlacement: F4SPlacement? { get }
    
    func checkUserCanApply(user: F4SUUID?,
                           to company: F4SUUID,
                           givenExistingPlacements existing: [F4STimelinePlacement],
                           completion: @escaping (F4SNetworkResult<Bool>) -> Void)
    
    func checkUserCanApply(user: F4SUUID?,
                           to company: F4SUUID,
                           completion: @escaping (F4SNetworkResult<Bool>) -> Void)
    
}
