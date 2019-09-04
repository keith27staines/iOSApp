//
//  F4SDatabaseDownloadManagerProtocol.swift
//  WorkfinderServices
//
//  Created by Keith Dev on 04/09/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

public protocol F4SDatabaseDownloadManagerProtocol : class {
    var localDatabaseDatestamp: Date? { get }
    func start()
    func registerObserver(_ observer: F4SCompanyDatabaseAvailabilityObserving)
    func removeObserver(_ observer: F4SCompanyDatabaseAvailabilityObserving)
    func ageOfLocalDatabase() -> TimeInterval
    func isLocalDatabaseAvailable() -> Bool
}

public protocol F4SCompanyDatabaseAvailabilityObserving : class {
    func newStagedDatabaseIsAvailable(url: URL)
    func newDatabaseIsDownloading(progress: Double)
}
