
public enum TrackingEventType {
    
    // MARK:- App lifecycle
    case first_use                                                              // checked
    case app_open
    
    // MARK:- Onboarding
    case onboarding_start                                                       // checked
    case onboarding_cancel
    case onboarding_tap_sign_in
    case onboarding_tap_just_get_started
    case onboarding_convert
    
    // MARK:- Main navigation
    case tab_tap(String)

    // MARK:- Register and sign in
    case register_user_start
    case register_user_cancel
    case register_user_convert
    
    // MARK:- Search
    case search_home_perform_typeahead(String)
    case search_home_perform_full(String)
    case search_home_perform_popular(String)
    case search_home_apply_filters(String)

    // MARK: Allow notifications
    case allow_notifications_start
    case allow_notifications_cancel
    case allow_notifications_convert

    // MARK: Recommendations deeplink processing
    case recommendation_deeplink_start
    case recommendation_deeplink_cancel
    case recommendation_deeplink_convert
    
    // MARK:- Offer deeplink processing
    case offer_deeplink_start
    case offer_deeplink_cancel
    case offer_deeplink_convert

    // MARK: Recommendations push notification processing
    case recommendation_pushnotification_start
    case recommendation_pushnotification_cancel
    case recommendation_pushnotification_convert

    /// MARK: Passive apply
    case passive_apply_start(ApplicationSource)
    case passive_apply_cancel(ApplicationSource)
    case passive_apply_convert(ApplicationSource)

    // MARK: Project apply
    case project_apply_start(ApplicationSource)
    case project_apply_cancel(ApplicationSource)
    case project_apply_convert(ApplicationSource)
    
    // MARK:- Cover letter events
    case letterView
    case letterEditor
    case questionOpened(PicklistType)
    case questionClosed(PicklistType, Bool)
    case letterCompleted
    
    // MARK:- Offer
    case offer_start
    case offer_cancel
    case offer_convert
    case offer_withdraw
    
    // MARK:- Object viewing
    case company_view
    case project_view(ApplicationSource)
    case association_view(ApplicationSource)

    public var name: String {
   
        switch self {
        
        // MARK:- App lifecycle
        case .first_use: return "ios_first_use"
        case .app_open: return "ios_app_open"
    
        // MARK:- Onboarding
        case .onboarding_start: return "ios_onboarding_start"
        case .onboarding_cancel: return  "ios_onboarding_cancel"
        case .onboarding_tap_sign_in: return "ios_tap_sign_in"
        case .onboarding_tap_just_get_started: return "ios_tap_just_get_started"
        case .onboarding_convert: return  "ios_onboarding_convert"
            
        // MARK:- Main navigation
        case .tab_tap: return "ios_tab_tap"
            
        // MARK:- Register and sign in
        case .register_user_start: return  "ios_register_user_start"
        case .register_user_cancel: return  "ios_register_user_cancel"
        case .register_user_convert: return  "ios_register_user_convert"
        
        // MARK:- Search
        case .search_home_perform_typeahead: return "ios_home_perform_typeahead_search"
        case .search_home_perform_full: return "ios_home_perform_full_search"
        case .search_home_perform_popular: return "ios_home_perform_popular_search"
        case .search_home_apply_filters: return "ios_home_apply_filters"
        
        // MARK: Allow notifications
        case .allow_notifications_start: return  "ios_allow_notifications_start"
        case .allow_notifications_cancel: return  "ios_allow_notifications_cancel"
        case .allow_notifications_convert: return  "ios_allow_notifications_convert"
            
        // MARK: Recommendations deeplink processing
        case .recommendation_deeplink_start: return  "ios_recommendation_deeplink_start"
        case .recommendation_deeplink_cancel: return  "ios_recommendation_deeplink_cancel"
        case .recommendation_deeplink_convert: return  "ios_recommendation_deeplink_convert"
            
        // MARK:- Offer deeplink processing
        case .offer_deeplink_start: return  "ios_offer_deeplink_start"
        case .offer_deeplink_cancel: return  "ios_offer_deeplink_cancel"
        case .offer_deeplink_convert: return  "ios_offer_deeplink_convert"
            
        // MARK: Recommendations push notification processing
        case .recommendation_pushnotification_start: return  "ios_recommendation_pushnotification_start"
        case .recommendation_pushnotification_cancel: return  "ios_recommendation_pushnotification_cancel"
        case .recommendation_pushnotification_convert: return  "ios_recommendation_pushnotification_convert"
            
        // MARK: Passive apply
        case .passive_apply_start: return  "ios_passive_apply_start"
        case .passive_apply_cancel: return  "ios_passive_apply_cancel"
        case .passive_apply_convert: return  "ios_passive_apply_convert"
            
        // MARK: Project apply
        case .project_apply_start: return  "ios_project_apply_start"
        case .project_apply_cancel: return  "ios_project_apply_cancel"
        case .project_apply_convert: return  "ios_project_apply_convert"
            
        // MARK:- Cover letter events
        case .letterView: return "ios_letter_view"
        case .letterEditor: return "ios_letter_editor"
        case .questionOpened: return "ios_question_opened"
        case .questionClosed: return "ios_question_closed"
        case .letterCompleted: return "ios_letter_completed"
            
        // MARK:- Offer
        case .offer_start: return  "ios_offer_start"
        case .offer_cancel: return  "ios_offer_cancel"
        case .offer_convert: return  "ios_offer_convert"
        case .offer_withdraw: return  "ios_offer_withdraw"
            
        // MARK:- Object viewing
        case .company_view: return "ios_companyView"
        case .project_view: return "ios_projectView"
        case .association_view: return "ios_associationView"
        }
    }
}

