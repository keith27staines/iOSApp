//
//  DatabaseService.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 11/15/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import SwiftyJSON


class DatabaseService: ApiBaseService {
    
    class var sharedInstance: DatabaseService {
        struct Static {
            static let instance: DatabaseService = DatabaseService()
        }
        return Static.instance
    }

    override init() {
    }

    private weak var databaseDownloadProtocol: DatabaseDownloadProtocol?

    func setDatabaseDownloadProtocol(viewCtrl: MapViewController) {
        self.databaseDownloadProtocol = viewCtrl
    }

    
    private (set) var isDownloadInProgress: Bool = false
    
    func getLatestDatabase() {
        if isDownloadInProgress == true { return }
        isDownloadInProgress = true
        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.getDatabaseMetadata {
                _, msg in
                switch msg
                {
                case let .value(boxedJson):
                    if strongSelf.shouldDownloadDatabase(createdDate: boxedJson.value.created) {
                        let directoryURL: URL = FileHelper.fileInDocumentsDirectory(filename: AppConstants.databaseFileName)
                        strongSelf.downloadDatabase(url: boxedJson.value.url, localUrlToSave: directoryURL, completed: {
                            _, msg in
                            switch msg
                            {
                            case let .error(error):
                                log.debug(error)
                                break
                            case let .deffinedError(error):
                                log.debug(error)
                                break
                            case .value:
                                UserDefaults.standard.set(boxedJson.value.created, forKey: UserDefaultsKeys.companyDatabaseCreatedDate)
                                DatabaseOperations.sharedInstance.reloadConection()
                            }
                            strongSelf.returnFromDownload()
                        })
                    } else {
                        // No download required, current DB is latest available
                        strongSelf.returnFromDownload()
                    }
                    return
                case let .error(error):
                    log.debug(error)
                    strongSelf.returnFromDownload()
                    return
                case let .deffinedError(error):
                    log.debug(error)
                    strongSelf.returnFromDownload()
                    return
                }
            }
        }
    }
    
    func returnFromDownload() {
        databaseDownloadProtocol?.finishDownloadProtocol()
        isDownloadInProgress = false
    }

    func getDatabaseMetadata(completed: @escaping (_ succeeded: Bool, _ msg: Result<CompanyDatabaseMeta>) -> Void) {
        let url = ApiConstants.companyDatabaseUrl
        get(url) {
            (_: Bool, msg: Result<JSON>) in
            switch msg
            {
            case let .value(boxedJson):
                let result = DeserializationManager.sharedInstance.parseLatestDatabaseVersion(jsonOptional: boxedJson.value)
                switch result
                {
                case .error:
                    completed(false, .deffinedError(Errors.GeneralCallErrors.GeneralError))

                case let .deffinedError(error):
                    completed(false, .deffinedError(error))

                case let .value(boxed):
                    completed(true, .value(Box(boxed.value)))
                }
            case .error:
               
               completed(false, .deffinedError(Errors.GeneralCallErrors.GeneralError))

            case let .deffinedError(error):
                completed(false, .deffinedError(error))
            }
        }
    }

    func downloadDatabase(url: String, localUrlToSave: URL, completed: @escaping (_ succeeded: Bool, _ msg: Result<String>) -> Void) {
        download(url, localUrlToSave: localUrlToSave) {
            (succeeded: Bool, msg: Result<String>) in
            completed(succeeded, msg)
        }
    }

    /// Returns true if there is a local database
    public func isLocalDatabaseAvailable() -> Bool {
        return DatabaseService.isLocalDatabaseAvailable()
    }
    
    /// Returns true if there is a local database
    public static func isLocalDatabaseAvailable() -> Bool {
        return createdDateForLocalDatabase() == nil ? false : true
    }
    
    /// Returns the creation date for the current local database if it exists, otherwise returns nil
    public static func createdDateForLocalDatabase() -> Date? {
        if let companyDatabaseCreatedDate = UserDefaults.standard.object(forKey: UserDefaultsKeys.companyDatabaseCreatedDate),
            let companyDatabaseCreatedDateString = companyDatabaseCreatedDate as? String,
            let companyDbCreatedDate = Date.dateFromRfc3339(string: companyDatabaseCreatedDateString) {
                return companyDbCreatedDate
        } else {
            return nil
        }
    }
    
    private func shouldDownloadDatabase(createdDate: String) -> Bool {
        guard let currentCreateDate = DatabaseService.createdDateForLocalDatabase(),
            let newCreateDate = Date.dateFromRfc3339(string: createdDate) else {
                return true
        }
        
        if currentCreateDate.isLessThanDate(dateToCompare: newCreateDate) {
            return true
        }
        return false
    }
}
