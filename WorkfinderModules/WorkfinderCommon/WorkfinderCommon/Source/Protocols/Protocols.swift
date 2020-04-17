
import Foundation

public typealias BackgroundSessionCompletionHandler = () -> Void
public typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]

/// Defines the interface for a locally persisting dictionary where they keys are elements of an enum
public protocol LocalStorageProtocol : class {
    func value(key: LocalStore.Key) -> Any?
    func setValue(_ value: Any?, for key: LocalStore.Key)
}

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

public protocol AppInstallationLogicProtocol : class {

}


