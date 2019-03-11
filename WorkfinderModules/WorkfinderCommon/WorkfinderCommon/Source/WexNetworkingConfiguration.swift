//
//  NetworkingConfiguration.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 10/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

public protocol WexNetworkingConfigurationProtocol {
    /// The key for the Workfinder (wex) api
    var wexApiKey: String { get }
    /// The full url of workfinder
    var baseUrlString: String { get }
    /// The full url of the Workfinder v1 api
    var v1ApiUrlString: String { get }
    /// The full url of the Workfinder v2 api
    var v2ApiUrlString: String { get }
}

public struct WexNetworkingConfiguration : WexNetworkingConfigurationProtocol {
    public var wexApiKey: String
    public var baseUrlString: String
    public var v1ApiUrlString: String
    public var v2ApiUrlString: String
    
    public init(
        wexApiKey: String,
        baseUrlString: String,
        v1ApiUrlString: String,
        v2ApiUrlString: String) {
        self.wexApiKey = wexApiKey
        self.baseUrlString = baseUrlString
        self.v1ApiUrlString = v1ApiUrlString
        self.v2ApiUrlString = v2ApiUrlString
    }
}
    
    
    //    public static let base: String = Config.BASE
    //    public static let baseUrl: String = Config.BASE_URL
    //    public static let baseUrl2: String = Config.BASE_URL2
    //
    //    // Company
    //    public static let companyDatabaseUrl: String = "\(baseUrl)/company/dump/full"
    //    public static let companyUrl: String = "\(baseUrl2)/company"
    //    public static let shortlistCompanyUrl: String = "\(baseUrl)/favourite"
    //    public static let unshortlistCompanyUrl: String = "\(baseUrl)/favourite"
    //    public static let companyDocumentsUrl: String = "\(baseUrl2)/company"
    //
    //    // User
    //    public static let userProfileUrl: String = "\(baseUrl)/device"
    //    public static let updateUserProfileUrl: String = "\(baseUrl)/user/"
    //
    //    // Placement
    //    public static let createPlacementUrl: String = "\(baseUrl)/placement"
    //    public static let updatePlacementUrl: String = "\(baseUrl)/placement"
    //    public static let patchPlacementUrl: String = "\(baseUrl2)/placement"
    //    public static let allPlacementsUrl: String = "\(baseUrl)/placement"
    //    public static let voucherUrl: String = "\(baseUrl)/voucher/"
    //    public static let roleUrl: String = "\(baseUrl2)/company"
    //    public static let offerUrl: String = "\(baseUrl2)/placement"
    //
    //    // Document upload
    //    public static let postDocumentsUrl: String = "\(baseUrl2)/placement"
    //
    //    // Messages
    //    public static let messagesInThreadUrl: String = "\(baseUrl)/messaging/"
    //    public static let optionsForThreadUrl: String = "\(baseUrl)/messaging/"
    //    public static let sendMessageForThreadUrl: String = "\(baseUrl)/messaging/"
    //    public static let unreadMessagesCountUrl: String = "\(baseUrl)/user/status"
    //
    //    // Template
    //    public static let templateUrl: String = "\(baseUrl)/cover-template"
    //
    //    // Misc
    //    public static let versionUrl: String = "\(base)/validation/ios-version/"
    //    public static let contentUrl: String = "\(baseUrl)/content"
    //    public static let ratingUrl: String = "\(baseUrl)/rating"
    //    public static let allPartnersUrl: String = "\(baseUrl2)/partner"
    //    public static let recommendationURL: String = "\(baseUrl)/recommend"


