
import Foundation
public typealias BackgroundSessionCompletionHandler = () -> Void
public protocol F4SDatabaseDownloadManagerProtocol : class {
    var backgroundSessionCompletionHandler: BackgroundSessionCompletionHandler? { get set }
    var localDatabaseDatestamp: Date? { get }
    func start()
    func registerObserver(_ observer: F4SCompanyDatabaseAvailabilityObserving)
    func removeObserver(_ observer: F4SCompanyDatabaseAvailabilityObserving)
    func ageOfLocalDatabase() -> TimeInterval
    func isLocalDatabaseAvailable() -> Bool
}

public protocol F4SCompanyDatabaseAvailabilityObserving : class {
    func newStagedDatabaseIsAvailable(url: URL)
    func newDatabaseIsDownloading(progress: Double)
}

public protocol AppInstallationUuidLogicProtocol : class {
    var registeredInstallationUuid: F4SUUID? { get }
    func ensureDeviceIsRegistered(completion: @escaping (F4SNetworkResult<F4SRegisterDeviceResult>)->())
}

public typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]
