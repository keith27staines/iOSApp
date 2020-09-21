public typealias TrackEventProperty = [String: Any]

public enum ScreenName: String {
    case notSpecified
    case companyClusterList
    case WorkplaceViewController
    case companySearch
    case map
}

public enum TrackEventType: String {
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
    
    case candidate_uc_onboarding_started
    case candidate_uc_onboarding_cancelled
    case candidate_uc_onboarding_converted
    
    case candidate_uc_register_user_started
    case candidate_uc_register_user_cancelled
    case candidate_uc_register_user_converted
    
    case candidate_uc_allow_location_user_started
    case candidate_uc_allow_location_cancelled
    case candidate_uc_allow_location_converted
    
    case candidate_uc_allow_notifications_user_started
    case candidate_uc_allow_notifications_cancelled
    case candidate_uc_allow_notifications_converted
    
    case candidate_uc_recommendation_deeplink_started
    case candidate_uc_recommendation_deeplink_cancelled
    case candidate_uc_recommendation_deeplink_converted
    
    case candidate_uc_offer_deeplink_started
    case candidate_uc_offer_deeplink_cancelled
    case candidate_uc_offer_deeplink_converted
    
    case candidate_uc_recommendation_pushNotification_started
    case candidate_uc_recommendation_pushNotification_cancelled
    case candidate_uc_recommendation_pushNotification_converted
    
    case candidate_uc_apply_started
    case candidate_uc_apply_cancelled
    case candidate_uc_apply_converted
    
    case candidate_uc_projectApply_started
    case candidate_uc_projectAply_cancelled
    case candidate_uc_projectApply_converted
    
    case candidate_uc_offer_started
    case candidate_uc_offer_cancelled
    case candidate_uc_offer_converted
    case candidate_uc_offer_candidateWithdrew
    
    
}

public struct TrackingEvent {
    public let name: String
    public let additionalProperties: [String: Any]?

    public init(type: TrackEventType, additionalProperties: [String:Any]? = nil) {
        self.name = type.rawValue
        self.additionalProperties = additionalProperties
    }
    
    public init(name: String, additionalProperties: [String:Any]? = nil) {
        self.name = name
        self.additionalProperties = additionalProperties
    }
    
}
