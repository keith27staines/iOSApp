import WorkfinderCommon

var logger: Logger?

public struct WorkfinderNetworking {
    public static var networkCallLogger: NetworkCallLogger? { return logger }
}

public var sharedSessionManager: WEXSessionManager!

func configureWEXSessionManager(configuration: WEXNetworkingConfigurationProtocol) throws {
    guard sharedSessionManager == nil else {
        throw WEXNetworkConfigurationError.sessionManagerMayOnlyBeConfiguredOnce
    }
    sharedSessionManager = WEXSessionManager(configuration: configuration)
}

public enum WEXNetworkConfigurationError : Error {
    case sessionManagerMayOnlyBeConfiguredOnce
}


public typealias HTTPHeaders = [String:String]
