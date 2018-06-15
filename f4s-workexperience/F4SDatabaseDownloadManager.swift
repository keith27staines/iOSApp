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
    
    public let successInterval: TimeInterval = 3600.0
    public let failedInterval: TimeInterval = 30.0
    
    private var databaseAvailabilityObservers = [F4SCompanyDatabaseAvailabilityObserving]()
    
    public func registerObserver(_ observer: F4SCompanyDatabaseAvailabilityObserving) {
        databaseAvailabilityObservers.append(observer)
    }
    public func removeObserver(_ observer: F4SCompanyDatabaseAvailabilityObserving) {
        print("TODO!!!")
    }
    
    private var databaseDownloadService: F4SDownloadService? = nil
    
    public private (set) var backgroundSessionCompletionHandler: BackgroundSessionCompletionHandler?
    
    public func isLocalDatabaseAvailable() -> Bool {
        return localDatabaseDatestamp != nil
    }
    
    public var localDatabaseDatestamp: Date? {
        
        return nil // UserDefaultsKeys.companyDatabaseCreatedDate
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
 
        let dbName = AppConstants.databaseFileName
        let localDBUrl: URL = FileHelper.fileInDocumentsDirectory(filename: dbName)
        let filemanager = FileManager.default
        guard filemanager.fileExists(atPath: localDBUrl.path) else {
            return
        }
        
        do {
            // Close database, notifying observers before and after that the database is being replaced
            databaseAvailabilityObservers.forEach({ (observer) in
                observer.databaseWillBecomeUnavailable()
            })
            DatabaseOperations.sharedInstance.disconnectDatabase()
            databaseAvailabilityObservers.forEach({ (observer) in
                observer.databaseDidBecomeUnavailable()
            })
            
            // Delete current database
            try filemanager.removeItem(at: localDBUrl)
            
            // Move new database from its temporary location to standard local position
            try FileManager.default.moveItem(at: tempUrl, to: localDBUrl)
            
            // Write downloadedDate to user defaults
            UserDefaults.standard.set(Date(), forKey: UserDefaultsKeys.companyDatabaseCreatedDate)
            
            // Reopen database connection
            databaseAvailabilityObservers.forEach({ (observer) in
                observer.databaseWillBecomeAvailable()
            })
            DatabaseOperations.sharedInstance.reloadConection()
            databaseAvailabilityObservers.forEach({ (observer) in
                observer.databaseDidBecomeUnavailable()
            })
            
            // Schedule next update
            scheduleNextCheckAfter(delay: successInterval)
            
        } catch {
            log.error(error)
        }
    }
    
    public func downloadServiceProgressed(_ service: F4SDownloadService, fractionComplete: Double) {

        // print("download fraction complete: \(fractionComplete)")
    }
}

public protocol F4SCompanyDatabaseAvailabilityObserving {
    func databaseWillBecomeUnavailable()
    func databaseDidBecomeUnavailable()
    func databaseWillBecomeAvailable()
    func databaseDidBecomeAvailable()
}
