
import Foundation

public class MockDatabaseDownloadManager : F4SCompanyDownloadManagerProtocol {
    
    public var stagedCompanyDownloadFileUrl: URL = URL(string: "stagedCompanyDownloadFileUrl")!
    
    
    // spies
    var registeredObservers = [F4SCompanyDownloadFileAvailabilityObserving]()
    var age: TimeInterval = 0
    var isAvailable: Bool = false
    
    // public interface
    public init() {}
    public var backgroundSessionCompletionHandler: BackgroundSessionCompletionHandler?
    public var companyDownloadFileDatestamp: Date?
    
    public func registerObserver(_ observer: F4SCompanyDownloadFileAvailabilityObserving) {
        registeredObservers.append(observer)
    }
    
    public func removeObserver(_ observer: F4SCompanyDownloadFileAvailabilityObserving) {
        registeredObservers.removeAll { (anObserver) -> Bool in
            anObserver === observer
        }
    }
    
    public func ageOfCompanyDownloadFile() -> TimeInterval {
        return age
    }
    
    public func isCompanyDownloadFileAvailable() -> Bool {
        return isAvailable
    }
    
    public func start() {}
}
