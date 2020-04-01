import Foundation

/// `WorkfinderEndpoint` defines the endpoints for every Workfinder service
/// currently used in the app
public struct WorkfinderEndpoint {
    
    public let workfinderApiUrlString: String
    
    public init(baseUrlString: String) {
        self.workfinderApiUrlString = baseUrlString
    }
    
    // Company
    public var companyDatabaseUrl: String { "\(workfinderApiUrlString)/company/dump/full" }
    public var companyUrl: String { "\(workfinderApiUrlString)/company" }
    public var companyDocumentsUrl: String { "\(workfinderApiUrlString)/company" }
    public var roleUrl: String { "\(workfinderApiUrlString)/company" }
    
    // favourited companies
    public var shortlistCompanyUrl: String { "\(workfinderApiUrlString)/favourite" }
    public var unshortlistCompanyUrl: String { "\(workfinderApiUrlString)/favourite" }
    
    // recommended companies
    public var recommendationURL: String { "\(workfinderApiUrlString)/recommend" }
    
    // User
    public var registerVendorId: String { "\(workfinderApiUrlString)/register" }
    public var registerPushNotifictionToken: String { "\(workfinderApiUrlString)/register" }
    public var updateUserProfileUrl: String { "\(workfinderApiUrlString)/user/me" }
    
    // user's referrer (partner)
    public var allPartnersUrl: String { "\(workfinderApiUrlString)/partner" }
    
    // Placement
    public var placementUrl: String { "\(workfinderApiUrlString)/placement" }
    public var patchPlacementUrl: String { "\(workfinderApiUrlString)/placement" }
    public var allPlacementsUrl: String { "\(workfinderApiUrlString)/placement" }
    public var offerUrl: String { "\(workfinderApiUrlString)/placement" }
    public var postDocumentsUrl: String { "\(workfinderApiUrlString)/placement" }
    
    // voucher validation
    public var voucherUrl: String { "\(workfinderApiUrlString)/voucher/" }
    
    // Messages
    public var messagesInThreadUrl: String { "\(workfinderApiUrlString)/messaging/" }
    public var optionsForThreadUrl: String { "\(workfinderApiUrlString)/messaging/" }
    public var sendMessageForThreadUrl: String { "\(workfinderApiUrlString)/messaging/" }
    public var unreadMessagesCountUrl: String { "\(workfinderApiUrlString)/user/status" }
    
    // Template
    public var templateUrl: String { "\(workfinderApiUrlString)/cover-template" }
    
    public var versionUrl: String { "\(workfinderApiUrlString)/validation/ios-version/" }
    public var contentUrl: String { "\(workfinderApiUrlString)/content" }


}
