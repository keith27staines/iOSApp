
import Foundation
import WorkfinderCommon
import WorkfinderServices

public class F4SDatabaseDownloadManager  : NSObject, F4SDatabaseDownloadManagerProtocol {
    
    struct BoxedObserver {
        weak var observer: F4SCompanyDatabaseAvailabilityObserving?
        public init(object: F4SCompanyDatabaseAvailabilityObserving) {
            observer = object
        }
    }
    
    /// Returns the time to wait before polling the server again if the last poll was successful
    public func successInterval() -> TimeInterval {
        return 3600.0
    }
    
    /// Returns the time to wait before polling based on the age of the current local database
    public func failedInterval() -> TimeInterval {
        let age = ageOfLocalDatabase()
        return failedInterval(age: age)
    }
    
    /// Returns the time to wait before polling based on a specified age of the current local database
    internal func failedInterval(age: TimeInterval) -> TimeInterval {
        let standardInterval = successInterval()
        if age < 24 * 3600.0 { return  standardInterval }
        if age < 7 * 24 * 3600 { return standardInterval / 100.0 }
        return 1.0
    }
    
    private var databaseAvailabilityObservers = [BoxedObserver]()
    
    public var backgroundSessionCompletionHandler: BackgroundSessionCompletionHandler? = nil
    
    public func registerObserver(_ observer: F4SCompanyDatabaseAvailabilityObserving) {
        let boxedObserver = BoxedObserver(object: observer)
        databaseAvailabilityObservers.append(boxedObserver)
    }
    public func removeObserver(_ observer: F4SCompanyDatabaseAvailabilityObserving) {
        guard let index = databaseAvailabilityObservers.firstIndex(where: { (boxedObserver) -> Bool in
            return observer === boxedObserver.observer
        }) else {
            return
        }
        databaseAvailabilityObservers.remove(at: index)
    }
    
    private var databaseDownloadService: F4SDownloadService? = nil
    
    public func isLocalDatabaseAvailable() -> Bool {
        return localDatabaseDatestamp != nil
    }
    
    public func ageOfLocalDatabase() -> TimeInterval {
        guard let timestamp = localDatabaseDatestamp else {
            return TimeInterval.greatestFiniteMagnitude
        }
        let age = Date().timeIntervalSince(timestamp)
        return age
    }
    
    public var localDatabaseDatestamp: Date? {
        let date = UserDefaults.standard.value(forKey: UserDefaultsKeys.companyDatabaseCreatedDate) as? Date
        return date
    }
    
    let metadataService: F4SCompanyDatabaseMetadataServiceProtocol
    
    public func getDatabaseMetadataFromServer(completion: @escaping (F4SNetworkResult<F4SCompanyDatabaseMetaData>)->()) {
        metadataService.getDatabaseMetadata { (result) in
            completion(result)
        }
    }
    
    var workerQueue = DispatchQueue(label: "F4SDatabaseDownloadManager.worker")
    
    public init(metadataService: F4SCompanyDatabaseMetadataServiceProtocol) {
        self.metadataService = metadataService
        super.init()
        self.databaseDownloadService = F4SDownloadService(delegate: self)
    }
    
    public func start() {
        beginUpdateLocalCompanyDatabaseIfNecessary()
    }
    
    private func beginUpdateLocalCompanyDatabaseIfNecessary() {
        guard databaseDownloadService?.isDownloading == false else {
            // We don't want to start a new download if one is already in progress
            return
        }
        guard let localDate = localDatabaseDatestamp else {
            // As there is no local database we must download one
            beginDatabaseDownload()
            return
        }
        
        // a local database exists but is it up to date? In order to test that, we download the latest database metadata from the server and test its timestamp against the timestamp of the local database
        getDatabaseMetadataFromServer { [weak self] (metaDataResult) in
            guard let strongSelf = self else { return }
            switch metaDataResult {
            case .error(_):
                strongSelf.scheduleNextCheckAfter(delay: strongSelf.failedInterval())
                break
            case .success(let metadata):
                guard let serverDate = metadata.created else {
                    strongSelf.scheduleNextCheckAfter(delay: strongSelf.failedInterval())
                    return
                }
                if localDate < serverDate {
                    // No need to schedule another check in this golden route case because the download handler with do it for us
                    strongSelf.beginDatabaseDownloadWithMetadata(metadata)
                }
            }
        }
    }
    
    private func scheduleNextCheckAfter(delay: TimeInterval) {
        workerQueue.asyncAfter(deadline: DispatchTime.now() + delay, execute: { [weak self] in
            self?.beginUpdateLocalCompanyDatabaseIfNecessary()
        })
    }
    
    private func beginDatabaseDownload() {
        getDatabaseMetadataFromServer { [weak self] (metadataResult) in
            switch metadataResult {
            case .error(_):
                break
            case .success(let metadata):
                self?.beginDatabaseDownloadWithMetadata(metadata)
            }
        }
    }
    
    private func beginDatabaseDownloadWithMetadata(_ metadata: F4SCompanyDatabaseMetaData) {
        guard
            let urlString = metadata.urlString,
            let url = URL(string: urlString)
        else { return }
        databaseDownloadService?.startDownload(from: url)
    }
}

extension F4SDatabaseDownloadManager : F4SDownloadServiceDelegate {
    public func downloadServiceFinishedBackgroundSession(_ service: F4SDownloadService) {
        DispatchQueue.main.async { [weak self] in
            guard let handler = self?.backgroundSessionCompletionHandler else {
                return
            }
            // according to Apple's documentation, this completion handler MUST be called on the main thread
            handler()
        }
    }
    
    
    public func downloadService(_ service: F4SDownloadService, didFailToDownloadWithError error: F4SNetworkError) {
        print("company database download failed! \(error)")
        scheduleNextCheckAfter(delay: failedInterval())
    }
    
    public func downloadService(_ service: F4SDownloadService, didFinishDownloadingToUrl tempUrl: URL) {
        
        defer { scheduleNextCheckAfter(delay: successInterval()) }
        
        let filemanager = FileManager.default
        guard filemanager.fileExists(atPath: tempUrl.path) else {
            return
        }
        
        do {
            // Get the url that the database must be staged to
            let stagedUrl = DatabaseOperations.sharedInstance.stagedDatabaseUrl
        
            // Delete existing staged database if one exists
            if filemanager.fileExists(atPath: stagedUrl.path) {
                try filemanager.removeItem(at: stagedUrl)
            }
            
            // Move newly downloaded database from its temporary download location to the staging position
            try FileManager.default.moveItem(at: tempUrl, to: stagedUrl)
            
            // Write downloadedDate to user defaults
            UserDefaults.standard.set(Date(), forKey: UserDefaultsKeys.companyDatabaseCreatedDate)
            
            // Advise observers that a new database is available at the staging location
            databaseAvailabilityObservers.forEach({ (boxedObserver) in
                boxedObserver.observer?.newStagedDatabaseIsAvailable(url: stagedUrl)
            })
            
        } catch {
            globalLog.error(error)
        }
    }
    
    public func downloadServiceProgressed(_ service: F4SDownloadService, fractionComplete: Double) {
        databaseAvailabilityObservers.forEach({ (boxedObserver) in
            boxedObserver.observer?.newDatabaseIsDownloading(progress: fractionComplete)
        })
    }
}
