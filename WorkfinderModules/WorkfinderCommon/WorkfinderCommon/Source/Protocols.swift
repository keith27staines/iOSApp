
import Foundation

public typealias BackgroundSessionCompletionHandler = () -> Void
public typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]

public protocol F4SCompanyDownloadManagerProtocol : class {
    var stagedCompanyDownloadFileUrl: URL { get }
    var backgroundSessionCompletionHandler: BackgroundSessionCompletionHandler? { get set }
    var companyDownloadFileDatestamp: Date? { get }
    func start()
    func registerObserver(_ observer: F4SCompanyDownloadFileAvailabilityObserving)
    func removeObserver(_ observer: F4SCompanyDownloadFileAvailabilityObserving)
    func ageOfCompanyDownloadFile() -> TimeInterval
    func isCompanyDownloadFileAvailable() -> Bool
}

public protocol F4SCompanyDownloadFileAvailabilityObserving : class {
    func newCompanyDownloadFileHasBeenStaged(url: URL)
    func newCompanyDownloadFileIsDownloading(progress: Double)
}

public protocol AppInstallationUuidLogicProtocol : class {
    var registeredInstallationUuid: F4SUUID? { get }
    func ensureDeviceIsRegistered(completion: @escaping (F4SNetworkResult<F4SRegisterDeviceResult>)->())
}


