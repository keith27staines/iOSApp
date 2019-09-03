//
//  CompanyViewData.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 29/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

public enum AppliedState {
    case notApplied
    case draft
    case applied
}

public protocol CompanyViewDataProtocol {
    var uuid: F4SUUID { get }
    var appliedState: AppliedState { get }
    var companyName: String { get }
    var isAvailableForSearch: Bool { get }
    var isFavourited: Bool { get }
    var starRating: Float? { get }
    var industry: String? { get }
    var description: String? { get }
    var revenue: Double? { get }
    var growth: Double? { get }
    var employees: Int? { get }
    var industryIsHidden: Bool { get }
    var duedilIsHiden: Bool { get }
    var linkedinIsHidden: Bool { get }
    var postcode: String? { get set }
    var duedilUrl: String? { get }
    var linkedinUrl: String? { get }
    var logoUrlString: String? { get }
}

public extension CompanyViewDataProtocol {
    var duedilIsHiden: Bool {
        return duedilUrl == nil || duedilUrl!.isEmpty
    }
    var linkedinIsHidden: Bool {
        return linkedinUrl == nil || linkedinUrl!.isEmpty
    }
}
