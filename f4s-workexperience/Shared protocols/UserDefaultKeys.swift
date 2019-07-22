
import Foundation

/// Gradually move from using these to using LocalStoreKeys in WorkfinderCommon

struct UserDefaultsKeys {
    static let invokingUrl = "invokingUrl"
    static let partnerID = "partnerID"
    static let hasParnerIDBeenSentToServer = "hasParnerIDBeenSentToServer"
    static let userUuid = "userUuid"
    static let companyDatabaseCreatedDate = "companyDatabaseCreatedDate"
    static let isFirstLaunch = "isFirstLaunch"
    static let vendorUuid = "vendorUuid"
    static let shouldLoadTimeline = "shouldLoadTimeline"
}
