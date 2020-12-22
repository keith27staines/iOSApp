
public typealias TrackEventProperty = [String: Any]

public enum ScreenName: String {
    case notSpecified
    case companyClusterList
    case WorkplaceViewController
    case companySearch
    case home
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

    // onboarding events are being logged
    case uc_onboarding_start
    case uc_onboarding_cancel
    case uc_onboarding_convert

    // register user events logged
    case uc_register_user_start
    case uc_register_user_cancel
    case uc_register_user_convert

    // location events logged
    case uc_allow_location_user_start
    case uc_allow_location_cancel
    case uc_allow_location_convert

    case uc_allow_notifications_user_start
    case uc_allow_notifications_cancel
    case uc_allow_notifications_convert

    // recommendation deeplink events tracked
    case uc_recommendation_deeplink_start
    case uc_recommendation_deeplink_cancel
    case uc_recommendation_deeplink_convert

    case uc_offer_deeplink_start
    case uc_offer_deeplink_cancel
    case uc_offer_deeplink_convert

    case uc_recommendation_pushNotification_start
    case uc_recommendation_pushNotification_cancel
    case uc_recommendation_pushNotification_convert

    // passive apply events logged
    case uc_apply_start(ApplicationSource)
    case uc_apply_cancel(ApplicationSource)
    case uc_apply_convert(ApplicationSource)

    // project apply events logged
    case uc_projectApply_start(ApplicationSource)
    case uc_projectApply_cancel(ApplicationSource)
    case uc_projectApply_convert(ApplicationSource)
    
    // object views
    case uc_projectView(ApplicationSource)
    case uc_associationView(ApplicationSource)

    case uc_offer_start
    case uc_offer_cancel
    case uc_offer_convert
    case uc_offer_withdraw
    
    public var name: String {
   
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
        case .uc_projectApply_cancel: return  "candidate_uc_projectApply_cancel"
        case .uc_projectApply_convert: return  "candidate_uc_projectApply_convert"
            
        case .uc_offer_start: return  "candidate_uc_offer_start"
        case .uc_offer_cancel: return  "candidate_uc_offer_cancel"
        case .uc_offer_convert: return  "candidate_uc_offer_convert"
        case .uc_offer_withdraw: return  "candidate_uc_offer_withdraw"
            
        case .uc_projectView: return "candidate_uc_projectView"
        case .uc_associationView: return "candidate_uc_associationView"
        
        case .firstUse: return "firstUse"
        case .appOpen: return "appOpen"
        case .tabTap: return "tabTap"
        case .companyView: return "companyView"
        case .applyStart: return "applyStart"
        case .applyComplete: return "applyComplete"
        case .registerUser: return "registerUser"
        case .signInUser: return "signInUser"
        case .projectApplyStart: return "projectApplyStart"
        case .projectApplyNext: return "projectApplyNext"
        case .projectApplyEdit: return "projectApplyEdit"
        case .projectApplyBack: return "projectApplyBack"
        case .projectApplyPreview: return "projectApplyPreview"
        case .projectApplySubmit: return "projectApplySubmit"
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
    
}
