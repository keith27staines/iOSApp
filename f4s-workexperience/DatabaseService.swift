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

    func getLatestDatabase() {
        DispatchQueue.global().async {
            self.getDatabaseMetadata {
                _, msg in
                switch msg
                {
                case let .value(boxedJson):
                    if DatabaseService.sharedInstance.shouldDownloadDatabase(createdDate: boxedJson.value.created) {
                        let directoryURL: URL = FileHelper.fileInDocumentsDirectory(filename: AppConstants.databaseFileName)
                        self.downloadDatabase(url: boxedJson.value.url, localUrlToSave: directoryURL, completed: {
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
                                self.databaseDownloadProtocol?.finishDownloadProtocol()
                            }
                        })
                    }
                    break
                case let .error(error):
                    log.debug(error)
                    break
                case let .deffinedError(error):
                    log.debug(error)
                    break
                }
            }
        }
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

    private func shouldDownloadDatabase(createdDate: String) -> Bool {
        guard let companyDatabaseCreatedDate = UserDefaults.standard.object(forKey: UserDefaultsKeys.companyDatabaseCreatedDate),
            let companyDatabaseCreatedDateString = companyDatabaseCreatedDate as? String,
            let companyDbCreatedDate = Date.dateFromRfc3339(string: companyDatabaseCreatedDateString),
            let newCreateDate = Date.dateFromRfc3339(string: createdDate) else {
            return true
        }

        if companyDbCreatedDate.isLessThanDate(dateToCompare: newCreateDate) {
            return true
        }

        return false
    }
}
