import Foundation

/// `WorkfinderEndpoint` defines the endpoints for every Workfinder service
/// currently used in the app
public struct WorkfinderEndpoint {
    
    init(baseUrlString: String) {
        self.base = baseUrlString
    }
    
    public let base: String
    public var baseUrl2: String { return "\(base)/v2" }
    
    // Company
    public var companyDatabaseUrl: String { "\(baseUrl2)/company/dump/full" }
    public var companyUrl: String { "\(baseUrl2)/company" }
    public var companyDocumentsUrl: String { "\(baseUrl2)/company" }
    public var roleUrl: String { "\(baseUrl2)/company" }
    
    // favourited companies
    public var shortlistCompanyUrl: String { "\(baseUrl2)/favourite" }
    public var unshortlistCompanyUrl: String { "\(baseUrl2)/favourite" }
    
    // recommended companies
    public var recommendationURL: String { "\(baseUrl2)/recommend" }
    
    // User
    public var registerVendorId: String { "\(baseUrl2)/register" }
    public var registerPushNotifictionToken: String { "\(baseUrl2)/register" }
    public var updateUserProfileUrl: String { "\(baseUrl2)/user/me" }
    
    // user's referrer (partner)
    public var allPartnersUrl: String { "\(baseUrl2)/partner" }
    
    // Placement
    public var patchPlacementUrl: String { "\(baseUrl2)/placement" }
    public var allPlacementsUrl: String { "\(baseUrl2)/placement" }
    public var offerUrl: String { "\(baseUrl2)/placement" }
    public var postDocumentsUrl: String { "\(baseUrl2)/placement" }
    
    // voucher validation
    public var voucherUrl: String { "\(baseUrl2)/voucher/" }
    
    // Messages
    public var messagesInThreadUrl: String { "\(baseUrl2)/messaging/" }
    public var optionsForThreadUrl: String { "\(baseUrl2)/messaging/" }
    public var sendMessageForThreadUrl: String { "\(baseUrl2)/messaging/" }
    public var unreadMessagesCountUrl: String { "\(baseUrl2)/user/status" }
    
    // Template
    public var templateUrl: String { "\(baseUrl2)/cover-template" }
    
    // off-v2 apis (apis not exposed through v2)
    public var versionUrl: String { "\(base)/validation/ios-version/" }
    public var contentUrl: String { "\(baseUrl2)/content" }


}
