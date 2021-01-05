
public enum TrackingEventType {
    
    // MARK:- App lifecycle                                                     // checked
    case first_use                                                              // ok
    case app_open                                                               // ok
    
    // MARK:- Onboarding                                                        // checked
    case onboarding_start                                                       // ok
    case onboarding_cancel                                                      // not used
    case onboarding_tap_sign_in                                                 // ok
    case onboarding_tap_just_get_started                                        // ok
    case onboarding_convert                                                     // ok
    
    // MARK:- Main navigation                                                   // checked
    case tab_tap(tabName: String)                                               // ok

    // MARK:- Register and sign in                                              // checked
    case register_user_start                                                    // ok
    case register_user_cancel                                                   // ok
    case register_user_convert                                                  // ok
    
    // MARK:- Search                                                            // checked
    case search_home_typeahead_start                                            // ok
    case search_home_selected_typeahead_item                                    // ok
    case search_home_cancel_typeahead                                           // ok
    case search_home_perform_full(search: String)                               // ok
    case search_home_perform_popular(search: String)                            // ok
    case search_home_apply_filters(search: String)                              // ok

    // MARK:- Allow notifications                                               // checking
    case allow_notifications_start                                              // not firing
    case allow_notifications_cancel                                             // not firing
    case allow_notifications_convert                                            // not firing

    // MARK:- Recommendations deeplink processing                               // checked
    case recommendation_deeplink_start                                          // ok
    case recommendation_deeplink_cancel                                         // not used
    case recommendation_deeplink_convert                                        // ok
    
    // MARK:- Placement deeplink processing                                     // checked
    case placement_deeplink_start                                               // ok
    case placement_deeplink_cancel                                              // not used
    case placement_deeplink_convert                                             // ok

    // MARK:- Recommendations push notification processing                      // checked
    case recommendation_pushnotification_start                                  // ok
    case recommendation_pushnotification_cancel                                 // not used
    case recommendation_pushnotification_convert                                // ok

    // MARK:-  Passive apply                                                    // checked
    case passive_apply_start(AppSource)                                         // ok
    case passive_apply_cancel(AppSource)                                        // ok
    case passive_apply_convert(AppSource)                                       // ok
    
    // MARK:- DOB capture                                                       // checked
    case date_of_birth_capture_start                                            // ok
    case date_of_birth_capture_cancel                                           // ok
    case date_of_birth_capture_convert(Date)                                    // ok

    // MARK:- Project apply                                                     // checked
    case project_apply_start(AppSource)                                         // ok
    case project_apply_cancel(AppSource)                                        // ok
    case project_apply_convert(AppSource)                                       // ok
    
    // MARK:- Placement funnel                                                  // checked
    case placement_funnel_start(AppSource)                                      // ok
    case placement_funnel_convert(AppSource)                                    // ok
    case placement_funnel_cancel(AppSource)                                     // ok
    
    // MARK:- Cover letter events                                               // checked
    case letter_start                                                           // ok
    case letter_viewed(isComplete: Bool)                                        // ok
    case letter_editor_opened                                                   // ok
    case letter_editor_closed                                                   // ok
    case question_opened(PicklistType)                                          // ok
    case question_closed(PicklistType, isAnswered: Bool)                        // ok
    case letter_convert                                                         // ok
    case letter_cancel(isComplete: Bool)                                        // ok
    
    // MARK:- Document upload                                                   // checked
    case document_upload_start                                                  // ok
    case document_upload_document_selected                                      // ok
    case document_upload_convert                                                // ok
    case document_upload_skip                                                   // ok
    
    // MARK:- Offer                                                             // checked
    case offer_accept                                                           // ok
    case offer_decline(reason: String)                                          // ok
    
    // MARK:- Object viewing                                                    // checked
    case company_hosts_page_view(AppSource)                                     // ok
    case company_hosts_page_dismiss(AppSource)                                  // ok
    case project_page_view(AppSource)                                           // ok
    case project_page_dismiss(AppSource)                                        // ok
    case application_page_view(AppSource)                                       // ok
    case application_page_dismiss(AppSource)                                    // ok
    case offer_page_view(AppSource)                                             // ok
    case offer_page_dismiss(AppSource)                                          // ok
 
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
        case .recommendation_deeplink_start: return "ios_recommendation_deeplink_start"
        case .recommendation_deeplink_cancel: return "ios_recommendation_deeplink_cancel"
        case .recommendation_deeplink_convert: return "ios_recommendation_deeplink_convert"
            
        // MARK:- Offer deeplink processing
        case .placement_deeplink_start: return "ios_placement_deeplink_start"
        case .placement_deeplink_cancel: return "ios_placement_deeplink_cancel"
        case .placement_deeplink_convert: return "ios_placement_deeplink_convert"
            
        // MARK: Recommendations push notification processing
        case .recommendation_pushnotification_start: return "ios_recommendation_pushnotification_start"
        case .recommendation_pushnotification_cancel: return "ios_recommendation_pushnotification_cancel"
        case .recommendation_pushnotification_convert: return "ios_recommendation_pushnotification_convert"
            
        // MARK: Passive apply
        case .passive_apply_start: return "ios_passive_apply_start"
        case .passive_apply_cancel: return "ios_passive_apply_cancel"
        case .passive_apply_convert: return  "ios_passive_apply_convert"
            
        // MARK:- DOB capture
        case .date_of_birth_capture_start: return "ios_dob_capture_start"       
        case .date_of_birth_capture_cancel: return "ios_dob_capture_cancel"     
        case .date_of_birth_capture_convert: return "ios_dob_capture_convert"
            
        // MARK:- Placement funnel
        case .placement_funnel_start: return "ios_placement_funnel_start"
        case .placement_funnel_convert: return "ios_placement_funnel_convert"
        case .placement_funnel_cancel: return "ios_placement_funnel_cancel"
            
        // MARK: Project apply
        case .project_apply_start: return "ios_project_apply_start"
        case .project_apply_cancel: return "ios_project_apply_cancel"
        case .project_apply_convert: return "ios_project_apply_convert"
            
        // MARK:- Cover letter events
        case .letter_start: return "ios_letter_start"
        case .letter_viewed: return "ios_letter_viewed"
        case .letter_editor_opened: return "ios_letter_editor_opened"
        case .letter_editor_closed: return "ios_letter_editor_closed"
        case .question_opened: return "ios_question_opened"
        case .question_closed: return "ios_question_closed"
        case .letter_cancel: return "ios_letter_cancel"
        case .letter_convert: return "ios_letter_convert"
            
        // MARK:- Document upload
        case .document_upload_start: return "ios_document_upload_start"
        case .document_upload_skip: return "ios_document_upload_skip"
        case .document_upload_convert: return "ios_document_upload_convert"
        case .document_upload_document_selected: return "ios_document_upload_document_selected"
            
        // MARK:- Offer
        case .offer_accept: return "ios_offer_accept"
        case .offer_decline: return "ios_offer_decline"
            
        // MARK:- Object viewing
        case .company_hosts_page_view: return "ios_company_hosts_page_view"
        case .company_hosts_page_dismiss: return "ios_company_hosts_page_dismiss"
        case .project_page_view: return "ios_project_page_view"
        case .project_page_dismiss: return "ios_project_page_dismiss"
        case .application_page_view: return "ios_application_page_view"
        case .application_page_dismiss: return "ios_application_page_dismiss"
        case .offer_page_view: return "ios_offer_page_view"
        case .offer_page_dismiss: return "ios_offer_page_dismiss"

        }
    }
}

