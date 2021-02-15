//
//  RequestAppReviewLogic.swift
//  WorkfinderUI
//
//  Created by Keith Staines on 11/02/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import Foundation

public class RequestAppReviewLogic {
    
    let localStore: LocalStorageProtocol
    public let ninetyDays: TimeInterval = 90 * 24 * 3600
    public let currentAppVersion: String
    public let requiredApplicationsSinceLastReview: Int
    
    /// This callback is used to notifiy that the logic has determined that a review should be requested.
    /// The callback itself is responsible for actually requesting the candidate to review the app
    public var makeRequestCallback: (() -> Void)?
    
    public init(
        localStore: LocalStorageProtocol = LocalStore(),
        currentAppVersion: String,
        requiredApplicationsSinceLastReview: Int = 3,
        makeRequestCallback: @escaping () -> Void) {
        self.localStore = localStore
        self.currentAppVersion = currentAppVersion
        self.requiredApplicationsSinceLastReview = requiredApplicationsSinceLastReview
        self.makeRequestCallback = makeRequestCallback
    }
    
    /// Returns the last request date if there was one, or a date in the distant past otherwise
    public var lastRequestDate: Date {
        localStore.value(key: LocalStore.Key.lastReviewRequestDate) as? Date ?? Date.distantPast
    }
    
    /// The version of the app when the candidate last reviewed it
    public var lastReviewedVersion: String? {
        localStore.value(key: .lastReviewedVersion) as? String
    }
    
    /// Returns `true` if the last request is older than 90 days, or if no request has been made yet
    public var isLastRequestOlderThan90Days: Bool {
        let intervalSinceLastRequest = Date().timeIntervalSince(lastRequestDate)
        return  intervalSinceLastRequest > ninetyDays
    }
    
    /// Returns `true` if the current versionof the app  is different from the version at the last review
    public var isCurrentVersionDifferentFromLastReviewedVersion: Bool {
        let current = SemanticVersion(versionString: currentAppVersion)
        guard
            let lastReviewed = SemanticVersion(versionString: lastReviewedVersion ?? "0.0.0")
        else { return true }
        return !(current ~= lastReviewed)
    }
    
    /// Returns true if the candidate has made sufficient applications to warrant another review
    public var isEnoughApplications: Bool {
        applicationCount > requiredApplicationsSinceLastReview
    }
    
    public func makeRequest() {
        incrementApplicationsCount()
        guard shouldMakeRequest else { return }
        localStore.setValue(Date(), for: .lastReviewRequestDate)
        localStore.setValue(currentAppVersion, for: .lastReviewedVersion)
        zeroApplicationsCount()
        makeRequestCallback?()
    }
    
    /// nobody will ever make this huge a number of applications
    let hugeNumber = 1000000
    
    /// Returns the number of applications made since the last review, or, if not yet recorded, then a huge number
    public var applicationCount: Int {
        localStore.value(key: .applicationsSinceLastReview) as? Int ?? hugeNumber
    }
    
    /// zeroes the recorded application count
    public func zeroApplicationsCount() {
        localStore.setValue(0, for: .applicationsSinceLastReview)
    }
    
    /// increments the recorded application count by one
    func incrementApplicationsCount() {
        let incrementedCount = applicationCount + 1
        localStore.setValue(incrementedCount, for: .applicationsSinceLastReview)
    }
    
    /// Returns true if
    /// (1) the last review request was more than 90 days ago,
    /// (2) the current version is different from the version that was last reviewed
    /// (3) the candidate has made more than the minimum number of applications
    public var shouldMakeRequest: Bool {
        isLastRequestOlderThan90Days &&
        isCurrentVersionDifferentFromLastReviewedVersion &&
        isEnoughApplications
    }
}
