//
//  F4SApiUrls.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 06/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public struct ApiConstants {
    public static let base: String = Config.BASE
    public static let baseUrl: String = Config.BASE_URL
    public static let baseUrl2: String = Config.BASE_URL2
    public static let versionUrl: String = "\(base)/validation/ios-version/"
    public static let userProfileUrl: String = "\(baseUrl)/device"
    public static let updateUserProfileUrl: String = "\(baseUrl)/user/"
    public static let companyDatabaseUrl: String = "\(baseUrl)/company/dump/full"
    public static let templateUrl: String = "\(baseUrl)/cover-template"
    public static let createPlacementUrl: String = "\(baseUrl)/placement"
    public static let updatePlacementUrl: String = "\(baseUrl)/placement"
    public static let contentUrl: String = "\(baseUrl)/content"
    public static let voucherUrl: String = "\(baseUrl)/voucher/"
    public static let messagesInThreadUrl: String = "\(baseUrl)/messaging/"
    public static let optionsForThreadUrl: String = "\(baseUrl)/messaging/"
    public static let sendMessageForThreadUrl: String = "\(baseUrl)/messaging/"
    public static let allPlacementsUrl: String = "\(baseUrl)/placement"
    public static let unreadMessagesCountUrl: String = "\(baseUrl)/user/status"
    public static let ratingUrl: String = "\(baseUrl)/rating"
    public static let shortlistCompanyUrl: String = "\(baseUrl)/favourite"
    public static let unshortlistCompanyUrl: String = "\(baseUrl)/favourite"
    public static let allPartnersUrl: String = "\(baseUrl2)/partner"
    public static let recommendationURL: String = "\(baseUrl)/recommend"
    public static let apiKey: String = "eTo0oeh4Yeen1oy7iDuv"
}