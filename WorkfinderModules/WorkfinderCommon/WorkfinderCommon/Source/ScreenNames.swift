
public typealias TrackEventProperty = [String: Any]

public enum ScreenName: String {
    case notSpecified
    case companyClusterList
    case WorkplaceViewController
    case companySearch
    case home
}

public enum TrackEventType {
    
    // MARK:- App lifecycle
    case firstUse
    case appOpen
    
    // MARK:- Onboarding
    case uc_onboarding_start
    case uc_onboarding_cancel
    case uc_onboarding_convert
    
    // MARK:- Main navigation
    case tabTap(String)

    // MARK:- Register and sign in
    case uc_register_user_start
    case uc_register_user_cancel
    case uc_register_user_convert

    // MARK: Allow notifications
    case uc_allow_notifications_user_start
    case uc_allow_notifications_cancel
    case uc_allow_notifications_convert

    // MARK: Recommendations deeplink processing
    case uc_recommendation_deeplink_start
    case uc_recommendation_deeplink_cancel
    case uc_recommendation_deeplink_convert
    
    // MARK:- Offer deeplink processing
    case uc_offer_deeplink_start
    case uc_offer_deeplink_cancel
    case uc_offer_deeplink_convert

    // MARK: Recommendations push notification processing
    case uc_recommendation_pushNotification_start
    case uc_recommendation_pushNotification_cancel
    case uc_recommendation_pushNotification_convert

    /// MARK: Passive apply
    case uc_apply_start(ApplicationSource)
    case uc_apply_cancel(ApplicationSource)
    case uc_apply_convert(ApplicationSource)

    // MARK: Project apply
    case uc_projectApply_start(ApplicationSource)
    case uc_projectApply_cancel(ApplicationSource)
    case uc_projectApply_convert(ApplicationSource)
    
    // MARK:- Cover letter events
    case letterView
    case letterEditor
    case questionOpened(PicklistType)
    case questionClosed(PicklistType, Bool)
    
    // MARK:- Offer
    case uc_offer_start
    case uc_offer_cancel
    case uc_offer_convert
    case uc_offer_withdraw
    
    // MARK:- Object viewing
    case companyView
    case uc_projectView(ApplicationSource)
    case uc_associationView(ApplicationSource)

    public var name: String {
   
        switch self {
        
        // MARK:- App lifecycle
        case .firstUse: return "firstUse"
        case .appOpen: return "appOpen"
    
        // MARK:- Onboarding
        case .uc_onboarding_start: return "candidate_uc_onboarding_start"
        case .uc_onboarding_cancel: return  "candidate_uc_onboarding_cancel"
        case .uc_onboarding_convert: return  "candidate_uc_onboarding_convert"
            
        // MARK:- Main navigation
        case .tabTap: return "tabTap"
            
        // MARK:- Register and sign in
        case .uc_register_user_start: return  "candidate_uc_register_user_start"
        case .uc_register_user_cancel: return  "candidate_uc_register_user_cancel"
        case .uc_register_user_convert: return  "candidate_uc_register_user_convert"
        
        // MARK: Allow notifications
        case .uc_allow_notifications_user_start: return  "candidate_uc_allow_notifications_user_start"
        case .uc_allow_notifications_cancel: return  "candidate_uc_allow_notifications_cancel"
        case .uc_allow_notifications_convert: return  "candidate_uc_allow_notifications_convert"
            
        // MARK: Recommendations deeplink processing
        case .uc_recommendation_deeplink_start: return  "candidate_uc_recommendation_deeplink_start"
        case .uc_recommendation_deeplink_cancel: return  "candidate_uc_recommendation_deeplink_cancel"
        case .uc_recommendation_deeplink_convert: return  "candidate_uc_recommendation_deeplink_convert"
            
        // MARK:- Offer deeplink processing
        case .uc_offer_deeplink_start: return  "candidate_uc_offer_deeplink_start"
        case .uc_offer_deeplink_cancel: return  "candidate_uc_offer_deeplink_cancel"
        case .uc_offer_deeplink_convert: return  "candidate_uc_offer_deeplink_convert"
            
        // MARK: Recommendations push notification processing
        case .uc_recommendation_pushNotification_start: return  "candidate_uc_recommendation_pushNotification_start"
        case .uc_recommendation_pushNotification_cancel: return  "candidate_uc_recommendation_pushNotification_cancel"
        case .uc_recommendation_pushNotification_convert: return  "candidate_uc_recommendation_pushNotification_convert"
            
        // MARK: Passive apply
        case .uc_apply_start: return  "candidate_uc_apply_start"
        case .uc_apply_cancel: return  "candidate_uc_apply_cancel"
        case .uc_apply_convert: return  "candidate_uc_apply_convert"
            
        // MARK: Project apply
        case .uc_projectApply_start: return  "candidate_uc_projectApply_start"
        case .uc_projectApply_cancel: return  "candidate_uc_projectApply_cancel"
        case .uc_projectApply_convert: return  "candidate_uc_projectApply_convert"
            
        // MARK:- Cover letter events
        case .letterView: return "letterView"
        case .letterEditor: return "letterEditor"
        case .questionOpened: return "questionOpened"
        case .questionClosed: return "questionClosed"
            
        // MARK:- Offer
        case .uc_offer_start: return  "candidate_uc_offer_start"
        case .uc_offer_cancel: return  "candidate_uc_offer_cancel"
        case .uc_offer_convert: return  "candidate_uc_offer_convert"
        case .uc_offer_withdraw: return  "candidate_uc_offer_withdraw"
            
        // MARK:- Object viewing
        case .companyView: return "companyView"
        case .uc_projectView: return "candidate_uc_projectView"
        case .uc_associationView: return "candidate_uc_associationView"

        }
    }
}

public struct TrackingEvent {
    public let type: TrackEventType
    public let additionalProperties: [String: Any]?

    
    public init(type: TrackEventType) {
        self.type = type
        self.additionalProperties = [:]
    }
    
    init(type: TrackEventType, additionalProperties: [String:Any]? = nil) {
        self.type = type
        self.additionalProperties = additionalProperties
    }
    
}
