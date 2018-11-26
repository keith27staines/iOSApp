//
//  Constants.swift
//  f4s-workexperience
//
//  Created by Andreea Rusu on 26/04/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit

struct Colors {
    static let white = 0xFFFFFF
    static let black = 0x000000
    static let azure = 0x2196F3
    static let waterBlue = 0x1976D2
    static let powderBlue = 0xBBDEFB
    static let mediumGreen = 0x40AF50
    static let warmGrey = 0x757575
    static let pinkishGrey = 0xBDBDBD
    static let darkGray = 0x4A4A4A
    static let normalGray = 0xEEEEEE

    static let mediumGray = 0x8F8E94
    static let lightGray = 0xEFEFF4
    static let gray = 0x6D6D72
    
    static let orangeNormal = 0xF6A623
    static let orangeYellow = 0xF69D00
    static let orangeActive = 0xFFC35F
    static let lightGreen = 0x45C658
    static let messageIncoming = 0xEAEAEA
    static let messageOutgoing = 0xE1FFC7
    static let messageOutgoingText = 0x000000
    static let messageIncomingText = 0x000000
    static let messageIncomingLink = 0x4A90E2
    static let messageOutgoingLink = 0x4A90E2
}

struct Style {
    static let smallerTextSize: CGFloat = 9
    static let verySmallTextSize: CGFloat = 11
    static let biggerVerySmallTextSize: CGFloat = 12
    static let smallTextSize: CGFloat = 13
    static let smallerMediumTextSize: CGFloat = 15
    static let mediumTextSize: CGFloat = 16
    static let biggerMediumTextSize: CGFloat = 17
    static let largeTextSize: CGFloat = 18
    static let biggerLargeTextSize = 20
    static let extraLargeTextSize: CGFloat = 22
    static let bigTextSize: CGFloat = 25
    static let hugeTextSize: CGFloat = 45
}

struct UserDefaultsKeys {
    static let invokingUrl = "invokingUrl"
    static let partnerID = "partnerID"
    static let hasParnerIDBeenSentToServer = "hasParnerIDBeenSentToServer"
    static let userUuid = "userUuid"
    static let userHasAccount = "userHasAccount"
    static let companyDatabaseCreatedDate = "companyDatabaseCreatedDate"
    static let isFirstLaunch = "isFirstLaunch"
    static let vendorUuid = "vendorUuid"
    static let shouldLoadTimeline = "shouldLoadTimeline"
}

struct GoogleApiKeys {
    static let googleApiKey = "AIzaSyAEph2YRDNaWwgHhrU0Qnd6izMoDQudeNs"
    static let geocodeApiKey = "AIzaSyAEph2YRDNaWwgHhrU0Qnd6izMoDQudeNs"
    static let placesUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    static let geocodeUrl = "https://maps.googleapis.com/maps/api/geocode/json"
}


struct AppConstants {
    static let databaseFileName = "company_database.db"
    static let stagedDatabaseFileName = "company_database.tmp"
    static let maximumNumberOfShortlists = 20
}
