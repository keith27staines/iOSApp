//
//  F4SDatabaseDownloadManager.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 13/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation


public typealias BackgroundSessionCompletionHandler = () -> Void

public class F4SDatabaseDownloadManager  : NSObject {
    
    struct BoxedObserver {
        weak var observer: F4SCompanyDatabaseAvailabilityObserving?
        public init(object: F4SCompanyDatabaseAvailabilityObserving) {
            observer = object
        }
    }
    
    public let successInterval: TimeInterval = 3600.0
    public let failedInterval: TimeInterval = 5.0
    
    private var databaseAvailabilityObservers = [BoxedObserver]()
    
    private var backgroundSessionCompletionHandler: BackgroundSessionCompletionHandler? = nil
    
    public func registerObserver(_ observer: F4SCompanyDatabaseAvailabilityObserving) {
        let boxedObserver = BoxedObserver(object: observer)
        databaseAvailabilityObservers.append(boxedObserver)
    }
    public func removeObserver(_ observer: F4SCompanyDatabaseAvailabilityObserving) {
        guard let index = databaseAvailabilityObservers.index(where: { (boxedObserver) -> Bool in
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
    
    public var localDatabaseDatestamp: Date? {
        let date = UserDefaults.standard.value(forKey: UserDefaultsKeys.companyDatabaseCreatedDate) as? Date
        return date
    }
    
    lazy var metadataService: F4SCompanyDatabaseMetadataServiceProtocol = {
        return F4SCompanyDatabaseMetadataService()
    }()
    
    public func getDatabaseMetadataFromServer(completion: @escaping (F4SNetworkResult<F4SCompanyDatabaseMetaData>)->()) {
        metadataService.getDatabaseMetadata { (result) in
            completion(result)
        }
    }
    
    var workerQueue = DispatchQueue(label: "F4SDatabaseDownloadManager.worker")
    
    public init(backgroundSessionCompletionHandler: BackgroundSessionCompletionHandler? = nil) {
        super.init()
        print("initializing with background session")
        self.backgroundSessionCompletionHandler = backgroundSessionCompletionHandler
    }
    
    public override init() {
        super.init()
        print("initializing without background session")
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
                strongSelf.scheduleNextCheckAfter(delay: strongSelf.failedInterval)
                break
            case .success(let metadata):
                guard let serverDate = metadata.created else {
                    strongSelf.scheduleNextCheckAfter(delay: strongSelf.failedInterval)
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
        scheduleNextCheckAfter(delay: failedInterval)
    }
    
    public func downloadService(_ service: F4SDownloadService, didFinishDownloadingToUrl tempUrl: URL) {
        
        defer { scheduleNextCheckAfter(delay: successInterval) }
        
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
            log.error(error)
        }
    }
    
    public func downloadServiceProgressed(_ service: F4SDownloadService, fractionComplete: Double) {
        databaseAvailabilityObservers.forEach({ (boxedObserver) in
            boxedObserver.observer?.newDatabaseIsDownloading(progress: fractionComplete)
        })
    }
}

public protocol F4SCompanyDatabaseAvailabilityObserving : class {
    func newStagedDatabaseIsAvailable(url: URL)
    func newDatabaseIsDownloading(progress: Double)
}
