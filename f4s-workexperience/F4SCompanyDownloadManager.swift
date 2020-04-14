
import Foundation
import WorkfinderCommon
import WorkfinderServices
import DataCompression

public class F4SCompanyDownloadManager  : NSObject, F4SCompanyDownloadManagerProtocol {
    
    /// Age in seconds at which the company download file is considered "stale"
    public let stalingInterval: TimeInterval = 24 * 3600
    
    struct BoxedObserver {
        weak var observer: F4SCompanyDownloadFileAvailabilityObserving?
        public init(object: F4SCompanyDownloadFileAvailabilityObserving) {
            observer = object
        }
    }

    /// Returns the time to wait before polling the server again if the last poll was successful
    public func successInterval() -> TimeInterval {
        return 3600.0
    }
    
    /// downloaded files are copied from their temporary download location to
    /// a "staging" url, and then held there until the app is ready to promote
    /// the staged file to a working file
    public var stagedCompanyDownloadFileUrl: URL {
        let stagedName = AppConstants.stagedDatabaseFileName
        let stagedUrl: URL = FileHelper.fileInDocumentsDirectory(filename: stagedName)
        return stagedUrl
    }
    
    /// Returns the time to wait before polling based on the age of the current local database
    public func failedInterval() -> TimeInterval {
        let age = ageOfCompanyDownloadFile()
        return failedInterval(age: age)
    }
    
    /// Returns the time to wait before polling based on a specified age of the current local database
    internal func failedInterval(age: TimeInterval) -> TimeInterval {
        let standardInterval = successInterval()
        if age < stalingInterval { return  standardInterval }
        if age < 10 * stalingInterval { return standardInterval / 100.0 }
        return 1.0
    }
    
    private var companyDownloadFileAvailabilityObservers = [BoxedObserver]()
    
    public var backgroundSessionCompletionHandler: BackgroundSessionCompletionHandler? = nil
    
    public func registerObserver(_ observer: F4SCompanyDownloadFileAvailabilityObserving) {
        let boxedObserver = BoxedObserver(object: observer)
        companyDownloadFileAvailabilityObservers.append(boxedObserver)
    }
    public func removeObserver(_ observer: F4SCompanyDownloadFileAvailabilityObserving) {
        guard let index = companyDownloadFileAvailabilityObservers.firstIndex(where: { (boxedObserver) -> Bool in
            return observer === boxedObserver.observer
        }) else {
            return
        }
        companyDownloadFileAvailabilityObservers.remove(at: index)
    }
    
    private var companyFileDownloadService: F4SDownloadService? = nil
    
    public func isCompanyDownloadFileAvailable() -> Bool {
        return companyDownloadFileDatestamp != nil
    }
    
    public func ageOfCompanyDownloadFile() -> TimeInterval {
        guard let timestamp = companyDownloadFileDatestamp else {
            return TimeInterval.greatestFiniteMagnitude
        }
        let age = Date().timeIntervalSince(timestamp)
        return age
    }
    
    public var companyDownloadFileDatestamp: Date? {
        return LocalStore().value(key: LocalStore.Key.companyDatabaseCreatedDate) as? Date
    }
    

    public func isCompanyDownloadFileStale() -> Bool {
        return ageOfCompanyDownloadFile() > stalingInterval
    }
    
    var workerQueue = DispatchQueue(label: "F4SDatabaseDownloadManager.worker")
    
    public override init() {
        super.init()
        self.companyFileDownloadService = F4SDownloadService(delegate: self)
    }
    
    public func start() {
        beginCompanyFileDownloadIfNecessary()
    }
    
    private func beginCompanyFileDownloadIfNecessary() {
        guard companyFileDownloadService?.isDownloading == false else { return }
        //guard isCompanyDownloadFileStale() == true else { return }
        beginCompanyFileDownload()
    }
    
    private func scheduleNextCheckAfter(delay: TimeInterval) {
        workerQueue.asyncAfter(deadline: DispatchTime.now() + delay, execute: { [weak self] in
            self?.beginCompanyFileDownloadIfNecessary()
        })
    }
    
    private func beginCompanyFileDownload() {
        companyFileDownloadService?.startDownload(from: companyFileDownloadFromUrl)
    }
    
    var companyFileDownloadFromUrl: URL {
        let urlString: String
        switch Config.environment {
        case .staging:
            urlString = "https://api-workfinder-com-develop.s3.eu-west-2.amazonaws.com/company-locations.jsonl.xz"
        case .production:
            urlString = "https://api-workfinder-com-master.s3.eu-west-2.amazonaws.com/company-locations.jsonl.xz"
        }
        return URL(string: urlString)!
    }
}

extension F4SCompanyDownloadManager : F4SDownloadServiceDelegate {
    public func downloadServiceFinishedBackgroundSession(_ service: F4SDownloadService) {
        guard let handler = self.backgroundSessionCompletionHandler else { return }
        // according to Apple's documentation, the completion handler MUST
        // be called on the main thread
        DispatchQueue.main.async { handler() }
    }
    
    
    public func downloadService(_ service: F4SDownloadService, didFailToDownloadWithError error: F4SNetworkError) {
        print("company database download failed! \(error)")
        scheduleNextCheckAfter(delay: failedInterval())
    }
    
    public func downloadService(_ service: F4SDownloadService, didFinishDownloadingToUrl tempUrl: URL) {
        
        defer { scheduleNextCheckAfter(delay: successInterval()) }
        
        let filemanager = FileManager.default
        guard filemanager.fileExists(atPath: tempUrl.path) else { return }
        
        do {
        
            // Delete existing staged database if one exists
            if filemanager.fileExists(atPath: stagedCompanyDownloadFileUrl.path) {
                try filemanager.removeItem(at: stagedCompanyDownloadFileUrl)
            }
            
            let compressedData = try Data(contentsOf: tempUrl)
            guard let decompressedData = compressedData.decompress(withAlgorithm: Data.CompressionAlgorithm.lzma) else { return }
            try decompressedData.write(to: stagedCompanyDownloadFileUrl)

            LocalStore().setValue(Date(), for: LocalStore.Key.companyDatabaseCreatedDate)
            
            // Advise observers that a new database is available at the staging location
            companyDownloadFileAvailabilityObservers.forEach({ (boxedObserver) in
                boxedObserver.observer?.newCompanyDownloadFileHasBeenStaged(url: stagedCompanyDownloadFileUrl)
            })
            
        } catch {
            // do nothing
        }
    }
    
    public func downloadServiceProgressed(_ service: F4SDownloadService, fractionComplete: Double) {
        companyDownloadFileAvailabilityObservers.forEach({ (boxedObserver) in
            boxedObserver.observer?.newCompanyDownloadFileIsDownloading(progress: fractionComplete)
        })
    }
    
    func promoteStagedDatabase() {
        guard FileHelper.fileExists(path: stagedCompanyDownloadFileUrl.path) else {
            return
        }
        FileHelper.moveFile(fromUrl: stagedCompanyDownloadFileUrl, toUrl: workingDatabaseUrl)
    }
    
    var workingDatabaseUrl: URL {
        let workingName = AppConstants.databaseFileName
        let workingUrl: URL = FileHelper.fileInDocumentsDirectory(filename: workingName)
        return workingUrl
    }
    
}


