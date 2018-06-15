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
    
    private struct BoxedObserver {
        weak var observed: NSObject?
        public init(object: NSObject) {
            observed = object
        }
    }
    
    public let successInterval: TimeInterval = 3600.0
    public let failedInterval: TimeInterval = 30.0
    
    private var databaseAvailabilityObservers = [F4SCompanyDatabaseAvailabilityObserving]()
    
    public func registerObserver(_ observer: F4SCompanyDatabaseAvailabilityObserving) {
        databaseAvailabilityObservers.append(observer)
    }
    public func removeObserver(_ observer: F4SCompanyDatabaseAvailabilityObserving) {
        guard let index = databaseAvailabilityObservers.index(where: { (otherObserver) -> Bool in
            return observer === otherObserver
        }) else {
            return
        }
        databaseAvailabilityObservers.remove(at: index)
    }
    
    private var databaseDownloadService: F4SDownloadService? = nil
    
    public private (set) var backgroundSessionCompletionHandler: BackgroundSessionCompletionHandler?
    
    public func isLocalDatabaseAvailable() -> Bool {
        return localDatabaseDatestamp != nil
    }
    
    public var localDatabaseDatestamp: Date? {
        let date = UserDefaults.standard.value(forKey: UserDefaultsKeys.companyDatabaseCreatedDate) as! Date?
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
        self.backgroundSessionCompletionHandler = backgroundSessionCompletionHandler
        super.init()
        self.databaseDownloadService = F4SDownloadService(sessionName: "F4SCompanyDatabase", delegate: self)
        
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

extension F4SDatabaseDownloadManager: URLSessionDelegate {
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async { [weak self] in
            if let completionHandler = self?.backgroundSessionCompletionHandler {
                self?.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
}

extension F4SDatabaseDownloadManager : F4SDownloadServiceDelegate {
    
    public func downloadService(_ service: F4SDownloadService, didFailToDownloadWithError error: F4SNetworkError) {
        print("download failed! \(error)")
        scheduleNextCheckAfter(delay: failedInterval)
    }
    
    public func downloadService(_ service: F4SDownloadService, didFinishDownloadingToUrl tempUrl: URL) {
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
            databaseAvailabilityObservers.forEach({ (observer) in
                observer.newStagedDatabaseIsAvailable(url: stagedUrl)
            })
            
            // Schedule next update
            scheduleNextCheckAfter(delay: successInterval)
            
        } catch {
            log.error(error)
        }
    }
    
    public func downloadServiceProgressed(_ service: F4SDownloadService, fractionComplete: Double) {
        // print("download fraction complete: \(fractionComplete)")
        databaseAvailabilityObservers.forEach({ (observer) in
            observer.newDatabaseIsDownloading(progress: fractionComplete)
        })
    }
}

public protocol F4SCompanyDatabaseAvailabilityObserving : class {
    func newStagedDatabaseIsAvailable(url: URL)
    func newDatabaseIsDownloading(progress: Double)
}
