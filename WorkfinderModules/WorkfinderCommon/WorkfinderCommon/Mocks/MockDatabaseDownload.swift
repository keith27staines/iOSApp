
import Foundation

public class MockDatabaseDownloadManager : F4SDatabaseDownloadManagerProtocol {
    
    // spies
    var registeredObservers = [F4SCompanyDatabaseAvailabilityObserving]()
    var age: TimeInterval = 0
    var isAvailable: Bool = false
    
    // public interface
    public init() {}
    public var backgroundSessionCompletionHandler: BackgroundSessionCompletionHandler?
    public var localDatabaseDatestamp: Date?
    
    public func registerObserver(_ observer: F4SCompanyDatabaseAvailabilityObserving) {
        registeredObservers.append(observer)
    }
    
    public func removeObserver(_ observer: F4SCompanyDatabaseAvailabilityObserving) {
        registeredObservers.removeAll { (anObserver) -> Bool in
            anObserver === observer
        }
    }
    
    public func ageOfLocalDatabase() -> TimeInterval {
        return age
    }
    
    public func isLocalDatabaseAvailable() -> Bool {
        return isAvailable
    }
    
    public func start() {}
}
