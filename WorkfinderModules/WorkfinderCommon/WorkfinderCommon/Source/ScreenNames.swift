public typealias TrackEventProperty = [String: Any]

public enum ScreenName: String {
    case notSpecified
    case companyClusterList
    case WorkplaceViewController
    case companySearch
    case map
}

public enum TrackEventType {
    
    case firstUse
    case appOpen
    case tabTap
    case companyView
    case applyStart
    case applyComplete
    
    case registerUser
    case signInUser
    
    case projectApplyStart
    case projectApplyNext
    case projectApplyEdit
    case projectApplyBack
    case projectApplyPreview
    case projectApplySubmit
    
    case uc_onboarding_start
    case uc_onboarding_cancel
    case uc_onboarding_convert
    
    case uc_register_user_start
    case uc_register_user_cancel
    case uc_register_user_convert
    
    case uc_allow_location_user_start
    case uc_allow_location_cancel
    case uc_allow_location_convert
    
    case uc_allow_notifications_user_start
    case uc_allow_notifications_cancel
    case uc_allow_notifications_convert
    
    case uc_recommendation_deeplink_start
    case uc_recommendation_deeplink_cancel
    case uc_recommendation_deeplink_convert
    
    case uc_offer_deeplink_start
    case uc_offer_deeplink_cancel
    case uc_offer_deeplink_convert
    
    case uc_recommendation_pushNotification_start
    case uc_recommendation_pushNotification_cancel
    case uc_recommendation_pushNotification_convert
    
    case uc_apply_start
    case uc_apply_cancel
    case uc_apply_convert
    
    case uc_projectApply_start
    case uc_projectAply_cancel
    case uc_projectApply_convert
    
    case uc_offer_start
    case uc_offer_cancel
    case uc_offer_convert
    case uc_offer_withdraw
    
    var name: String {
    
        switch self {
    
        case .uc_onboarding_start: return "candidate_uc_onboarding_start"
        case .uc_onboarding_cancel: return  "candidate_uc_onboarding_cancel"
        case .uc_onboarding_convert: return  "candidate_uc_onboarding_convert"
            
        case .uc_register_user_start: return  "candidate_uc_register_user_start"
        case .uc_register_user_cancel: return  "candidate_uc_register_user_cancel"
        case .uc_register_user_convert: return  "candidate_uc_register_user_convert"
            
        case .uc_allow_location_user_start: return  "candidate_uc_allow_location_user_start"
        case .uc_allow_location_cancel: return  "candidate_uc_allow_location_cancel"
        case .uc_allow_location_convert: return  "candidate_uc_allow_location_convert"
            
        case .uc_allow_notifications_user_start: return  "candidate_uc_allow_notifications_user_start"
        case .uc_allow_notifications_cancel: return  "candidate_uc_allow_notifications_cancel"
        case .uc_allow_notifications_convert: return  "candidate_uc_allow_notifications_convert"
            
        case .uc_recommendation_deeplink_start: return  "candidate_uc_recommendation_deeplink_start"
        case .uc_recommendation_deeplink_cancel: return  "candidate_uc_recommendation_deeplink_cancel"
        case .uc_recommendation_deeplink_convert: return  "candidate_uc_recommendation_deeplink_convert"
            
        case .uc_offer_deeplink_start: return  "candidate_uc_offer_deeplink_start"
        case .uc_offer_deeplink_cancel: return  "candidate_uc_offer_deeplink_cancel"
        case .uc_offer_deeplink_convert: return  "candidate_uc_offer_deeplink_convert"
            
        case .uc_recommendation_pushNotification_start: return  "candidate_uc_recommendation_pushNotification_start"
        case .uc_recommendation_pushNotification_cancel: return  "candidate_uc_recommendation_pushNotification_cancel"
        case .uc_recommendation_pushNotification_convert: return  "candidate_uc_recommendation_pushNotification_convert"
            
        case .uc_apply_start: return  "candidate_uc_apply_start"
        case .uc_apply_cancel: return  "candidate_uc_apply_cancel"
        case .uc_apply_convert: return  "candidate_uc_apply_convert"
            
        case .uc_projectApply_start: return  "candidate_uc_projectApply_start"
        case .uc_projectAply_cancel: return  "candidate_uc_projectAply_cancel"
        case .uc_projectApply_convert: return  "candidate_uc_projectApply_convert"
            
        case .uc_offer_start: return  "candidate_uc_offer_start"
        case .uc_offer_cancel: return  "candidate_uc_offer_cancel"
        case .uc_offer_convert: return  "candidate_uc_offer_convert"
        case .uc_offer_withdraw: return  "candidate_uc_offer_withdraw"
        case .firstUse: return "firstUse"
        case .appOpen: return "appOpen"
        case .tabTap: return "tabTap"
        case .companyView: return "companyView"
        case .applyStart: return ""
        case .applyComplete: return ""
        case .registerUser: return ""
        case .signInUser: return ""
        case .projectApplyStart: return ""
        case .projectApplyNext: return ""
        case .projectApplyEdit: return ""
        case .projectApplyBack: return ""
        case .projectApplyPreview: return ""
        case .projectApplySubmit: return ""
        }
    }
}

public struct TrackingEvent {
    public let type: TrackEventType
    public let additionalProperties: [String: Any]?

    public init(type: TrackEventType, additionalProperties: [String:Any]? = nil) {
        self.type = type
        self.additionalProperties = additionalProperties
    }
    
//    public init(name: String, additionalProperties: [String:Any]? = nil) {
//        self.name = name
//        self.additionalProperties = additionalProperties
//    }
    
}
