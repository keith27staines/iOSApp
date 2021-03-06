
import Foundation

public typealias BackgroundSessionCompletionHandler = () -> Void
public typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]



public protocol F4SCompanyDownloadManagerProtocol : AnyObject {
    var stagedCompanyDownloadFileUrl: URL { get }
    var backgroundSessionCompletionHandler: BackgroundSessionCompletionHandler? { get set }
    var companyDownloadFileDatestamp: Date? { get }
    func start()
    func registerObserver(_ observer: F4SCompanyDownloadFileAvailabilityObserving)
    func removeObserver(_ observer: F4SCompanyDownloadFileAvailabilityObserving)
    func ageOfCompanyDownloadFile() -> TimeInterval
    func isCompanyDownloadFileAvailable() -> Bool
}

public protocol F4SCompanyDownloadFileAvailabilityObserving : AnyObject {
    func newCompanyDownloadFileHasBeenStaged(url: URL)
    func newCompanyDownloadFileIsDownloading(progress: Double)
}




