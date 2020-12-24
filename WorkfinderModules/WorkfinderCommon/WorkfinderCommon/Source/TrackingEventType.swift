
public enum TrackingEventType {
    
    // MARK:- App lifecycle                                                     // checked
    case first_use                                                              // ok
    case app_open                                                               // ok
    
    // MARK:- Onboarding                                                        // checked
    case onboarding_start                                                       // ok
    case onboarding_cancel                                                      // ok
    case onboarding_tap_sign_in                                                 // ok
    case onboarding_tap_just_get_started                                        // ok
    case onboarding_convert                                                     // ok
    
    // MARK:- Main navigation                                                   // checked
    case tab_tap(String)                                                        // ok

    // MARK:- Register and sign in                                              // checked
    case register_user_start                                                    // ok
    case register_user_cancel                                                   // ok
    case register_user_convert                                                  // ok
    
    // MARK:- Search                                                            // checking
    case search_home_typeahead_start                                            // ok
    case search_home_selected_typeahead_item                                    // ?
    case search_home_cancel_typeahead                                           // ok
    case search_home_perform_full(String)                                       // ok
    case search_home_perform_popular(String)                                    // ok
    case search_home_apply_filters(String)                                      // ok

    // MARK:- Allow notifications
    case allow_notifications_start
    case allow_notifications_cancel
    case allow_notifications_convert

    // MARK:- Recommendations deeplink processing
    case recommendation_deeplink_start
    case recommendation_deeplink_cancel
    case recommendation_deeplink_convert
    
    // MARK:- Offer deeplink processing
    case offer_deeplink_start
    case offer_deeplink_cancel
    case offer_deeplink_convert

    // MARK:- Recommendations push notification processing
    case recommendation_pushnotification_start
    case recommendation_pushnotification_cancel
    case recommendation_pushnotification_convert

    // MARK:-  Passive apply
    case passive_apply_start(AppSource)
    case passive_apply_cancel(AppSource)
    case passive_apply_convert(AppSource)

    // MARK:- Project apply
    case project_apply_start(AppSource)
    case project_apply_cancel(AppSource)
    case project_apply_convert(AppSource)
    
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
    case company_details_page_view
    case project_page_view(AppSource)
    case application_page_view(AppSource)
 
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
        case .search_home_typeahead_start: return "ios_home_typeahead_start"
        case .search_home_selected_typeahead_item: return "ios_home_typeahead_selected_item"
        case .search_home_cancel_typeahead: return "ios_home_cancel_typeahead_search"
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
        case .company_details_page_view: return "ios_company_details_page_view"
        case .project_page_view: return "ios_project_page_view"
        case .application_page_view: return "ios_application_page_view"
        }
    }
}

