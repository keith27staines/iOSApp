//
//  F4SApiUrls.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 06/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public struct ApiConstants {
    public static let apiKey: String = "eTo0oeh4Yeen1oy7iDuv"
    public static let base: String = Config.BASE
    public static let baseUrl: String = Config.BASE_URL
    public static let baseUrl2: String = Config.BASE_URL2
    
    // Company
    public static let companyDatabaseUrl: String = "\(baseUrl2)/company/dump/full"
    public static let companyUrl: String = "\(baseUrl2)/company"
    public static let shortlistCompanyUrl: String = "\(baseUrl2)/favourite"
    public static let unshortlistCompanyUrl: String = "\(baseUrl2)/favourite"
    public static let companyDocumentsUrl: String = "\(baseUrl2)/company"
    public static let roleUrl: String = "\(baseUrl2)/company"
    
    // User
    public static let registerVendorId: String = "\(baseUrl2)/register"
    public static let updateUserProfileUrl: String = "\(baseUrl)/user/"
    
    // Placement
    public static let patchPlacementUrl: String = "\(baseUrl2)/placement"
    public static let allPlacementsUrl: String = "\(baseUrl2)/placement"
    public static let offerUrl: String = "\(baseUrl2)/placement"
    
    // voucher
    public static let voucherUrl: String = "\(baseUrl2)/voucher/"
    
    // Document upload
    public static let postDocumentsUrl: String = "\(baseUrl2)/placement"
    
    // Messages
    public static let messagesInThreadUrl: String = "\(baseUrl2)/messaging/"
    public static let optionsForThreadUrl: String = "\(baseUrl2)/messaging/"
    public static let sendMessageForThreadUrl: String = "\(baseUrl2)/messaging/"
    public static let unreadMessagesCountUrl: String = "\(baseUrl2)/user/status"
    
    // Template
    public static let templateUrl: String = "\(baseUrl2)/cover-template"
    
    // Misc
    public static let versionUrl: String = "\(base)/validation/ios-version/"
    public static let contentUrl: String = "\(baseUrl2)/content"
    public static let allPartnersUrl: String = "\(baseUrl2)/partner"
    public static let recommendationURL: String = "\(baseUrl2)/recommend"

}
