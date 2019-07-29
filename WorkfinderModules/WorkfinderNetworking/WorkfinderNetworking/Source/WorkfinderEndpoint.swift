import Foundation

/// `WorkfinderEndpoint` defines the endpoints for every Workfinder service
/// currently used in the app
public struct WorkfinderEndpoint {
    
    public static let base: String = NetworkConfig.workfinderApi
    public static let baseUrl2: String = NetworkConfig.workfinderApiV2
    
    // Company
    public static let companyDatabaseUrl: String = "\(baseUrl2)/company/dump/full"
    public static let companyUrl: String = "\(baseUrl2)/company"
    public static let companyDocumentsUrl: String = "\(baseUrl2)/company"
    public static let roleUrl: String = "\(baseUrl2)/company"
    
    // favourited companies
    public static let shortlistCompanyUrl: String = "\(baseUrl2)/favourite"
    public static let unshortlistCompanyUrl: String = "\(baseUrl2)/favourite"
    
    // recommended companies
    public static let recommendationURL: String = "\(baseUrl2)/recommend"
    
    // User
    public static let registerVendorId: String = "\(baseUrl2)/register"
    public static let registerPushNotifictionToken: String = "\(baseUrl2)/register"
    public static let updateUserProfileUrl: String = "\(baseUrl2)/user/me"
    
    // user's referrer (partner)
    public static let allPartnersUrl: String = "\(baseUrl2)/partner"
    
    // Placement
    public static let patchPlacementUrl: String = "\(baseUrl2)/placement"
    public static let allPlacementsUrl: String = "\(baseUrl2)/placement"
    public static let offerUrl: String = "\(baseUrl2)/placement"
    public static let postDocumentsUrl: String = "\(baseUrl2)/placement"
    
    // voucher validation
    public static let voucherUrl: String = "\(baseUrl2)/voucher/"
    
    // Messages
    public static let messagesInThreadUrl: String = "\(baseUrl2)/messaging/"
    public static let optionsForThreadUrl: String = "\(baseUrl2)/messaging/"
    public static let sendMessageForThreadUrl: String = "\(baseUrl2)/messaging/"
    public static let unreadMessagesCountUrl: String = "\(baseUrl2)/user/status"
    
    // Template
    public static let templateUrl: String = "\(baseUrl2)/cover-template"
    
    // off-v2 apis (apis not exposed through v2)
    public static let versionUrl: String = "\(base)/validation/ios-version/"
    public static let contentUrl: String = "\(baseUrl2)/content"


}
