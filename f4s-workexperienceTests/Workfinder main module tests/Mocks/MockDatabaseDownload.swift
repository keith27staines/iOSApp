//
//  MockDatabaseDownload.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 20/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderServices
@testable import f4s_workexperience

class MockDatabaseDownloadManager : F4SDatabaseDownloadManagerProtocol {
    
    // spies
    var registeredObservers = [F4SCompanyDatabaseAvailabilityObserving]()
    
    var age: TimeInterval = 0
    var isAvailable: Bool = false
    
    // interface
    var localDatabaseDatestamp: Date?
    
    func registerObserver(_ observer: F4SCompanyDatabaseAvailabilityObserving) {
        registeredObservers.append(observer)
    }
    
    func removeObserver(_ observer: F4SCompanyDatabaseAvailabilityObserving) {
        registeredObservers.removeAll { (anObserver) -> Bool in
            anObserver === observer
        }
    }
    
    func ageOfLocalDatabase() -> TimeInterval {
        return age
    }
    
    func isLocalDatabaseAvailable() -> Bool {
        return isAvailable
    }
    
    func start() {}
}
