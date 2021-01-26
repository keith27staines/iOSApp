
public enum TrackingEventType: Equatable {
    
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

extension TrackingEventType: Codable {
    
    enum CodingKeys: CodingKey {
        // MARK:- App lifecycle
        case first_use
        case app_open
        
        // MARK:- Onboarding
        case onboarding_start
        case onboarding_cancel
        case onboarding_tap_sign_in
        case onboarding_tap_just_get_started
        case onboarding_convert
        
        // MARK:- Main navigation
        case tab_tap                                                            // (tabName: String)

        // MARK:- Register and sign in
        case register_user_start
        case register_user_cancel
        case register_user_convert
        
        // MARK:- Search
        case search_home_typeahead_start
        case search_home_selected_typeahead_item
        case search_home_cancel_typeahead
        case search_home_perform_full                                           // (search: String)
        case search_home_perform_popular                                        // (search: String)
        case search_home_apply_filters                                          // (search: String)

        // MARK:- Allow notifications
        case allow_notifications_start
        case allow_notifications_cancel
        case allow_notifications_convert

        // MARK:- Recommendations deeplink processing
        case recommendation_deeplink_start
        case recommendation_deeplink_cancel
        case recommendation_deeplink_convert
        
        // MARK:- Placement deeplink processing
        case placement_deeplink_start
        case placement_deeplink_cancel
        case placement_deeplink_convert

        // MARK:- Recommendations push notification processing
        case recommendation_pushnotification_start
        case recommendation_pushnotification_cancel
        case recommendation_pushnotification_convert

        // MARK:-  Passive apply
        case passive_apply_start                                                // (AppSource)
        case passive_apply_cancel                                               // (AppSource)
        case passive_apply_convert                                              // (AppSource)
        
        // MARK:- DOB capture
        case date_of_birth_capture_start
        case date_of_birth_capture_cancel
        case date_of_birth_capture_convert                                      // (Date)

        // MARK:- Project apply
        case project_apply_start                                                // (AppSource)
        case project_apply_cancel                                               // (AppSource)
        case project_apply_convert                                              // (AppSource)
        
        // MARK:- Placement funnel
        case placement_funnel_start                                             // (AppSource)
        case placement_funnel_convert                                           // (AppSource)
        case placement_funnel_cancel                                            // (AppSource)
        
        // MARK:- Cover letter events
        case letter_start
        case letter_viewed                                                      // (isComplete: Bool)
        case letter_editor_opened
        case letter_editor_closed
        case question_opened                                                    // (PicklistType)
        case question_closed                                                    // (PicklistType, isAnswered: Bool)
        case letter_convert
        case letter_cancel                                                      // (isComplete: Bool)
        
        // MARK:- Document upload
        case document_upload_start
        case document_upload_document_selected
        case document_upload_convert
        case document_upload_skip
        
        // MARK:- Offer
        case offer_accept
        case offer_decline                                                      // (reason: String)
        
        // MARK:- Object viewing
        case company_hosts_page_view                                            // (AppSource)
        case company_hosts_page_dismiss                                         // (AppSource)
        case project_page_view                                                  // (AppSource)
        case project_page_dismiss                                               // (AppSource)
        case application_page_view                                              // (AppSource)
        case application_page_dismiss                                           // (AppSource)
        case offer_page_view                                                    // (AppSource)
        case offer_page_dismiss                                                 // (AppSource)

    }
    
    enum CodingError: Error {
        case failedToFindCodingKey
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let key = container.allKeys.first else {
            throw CodingError.failedToFindCodingKey
        }
        
        switch key {
//        case .appStart:
//            self = .appStart
//        case .application:
//            let source = try container.decode(
//                AppSource.self,
//                forKey: .application
//            )
//            self = .application(source: source)
//        case .search:
//            var nestedContainer = try container.nestedUnkeyedContainer(forKey: .search)
//            let term = try nestedContainer.decode(String.self)
//            let source = try nestedContainer.decode(AppSource.self)
//            self = .search(term: term, source: source)
        
        case .first_use:
            self = .first_use
        case .app_open:
            self = .app_open
        case .onboarding_start:
            self = .onboarding_start
        case .onboarding_cancel:
            self = .onboarding_cancel
        case .onboarding_tap_sign_in:
            self = .onboarding_tap_sign_in
        case .onboarding_tap_just_get_started:
            self = .onboarding_tap_just_get_started
        case .onboarding_convert:
            self = .onboarding_convert
        case .tab_tap:
            let tabName = try container.decode(String.self, forKey: .tab_tap)
            self = .tab_tap(tabName: tabName)
        case .register_user_start:
            self = .register_user_start
        case .register_user_cancel:
            self = .register_user_cancel
        case .register_user_convert:
            self = .register_user_convert
        case .search_home_typeahead_start:
            self = .search_home_typeahead_start
        case .search_home_selected_typeahead_item:
            self = .search_home_selected_typeahead_item
        case .search_home_cancel_typeahead:
            self = .search_home_cancel_typeahead
        case .search_home_perform_full:
            let search = try container.decode(String.self, forKey: .search_home_perform_full)
            self = .search_home_perform_full(search: search)
        case .search_home_perform_popular:
            let search = try container.decode(String.self, forKey: .search_home_perform_popular)
            self = .search_home_perform_popular(search: search)
        case .search_home_apply_filters:
            let search = try container.decode(String.self, forKey: .search_home_apply_filters)
            self = .search_home_apply_filters(search: search)
        case .allow_notifications_start:
            self = .allow_notifications_start
        case .allow_notifications_cancel:
            self = .allow_notifications_cancel
        case .allow_notifications_convert:
            self = .allow_notifications_convert
        case .recommendation_deeplink_start:
            self = .recommendation_deeplink_start
        case .recommendation_deeplink_cancel:
            self = .recommendation_deeplink_cancel
        case .recommendation_deeplink_convert:
            self = .recommendation_deeplink_convert
        case .placement_deeplink_start:
            self = .placement_deeplink_start
        case .placement_deeplink_cancel:
            self = .placement_deeplink_cancel
        case .placement_deeplink_convert:
            self = .placement_deeplink_convert
        case .recommendation_pushnotification_start:
            self = .recommendation_pushnotification_start
        case .recommendation_pushnotification_cancel:
            self = .recommendation_pushnotification_cancel
        case .recommendation_pushnotification_convert:
            self = .recommendation_pushnotification_convert
        case .passive_apply_start:
            let source = try container.decode(AppSource.self, forKey: .passive_apply_start)
            self = .passive_apply_start(source)
        case .passive_apply_cancel:
            let source = try container.decode(AppSource.self, forKey: .passive_apply_cancel)
            self = .passive_apply_cancel(source)
        case .passive_apply_convert:
            let source = try container.decode(AppSource.self, forKey: .passive_apply_convert)
            self = .passive_apply_convert(source)
        case .date_of_birth_capture_start:
            self = .date_of_birth_capture_start
        case .date_of_birth_capture_cancel:
            self = .date_of_birth_capture_cancel
        case .date_of_birth_capture_convert:
            let dob = try container.decode(Date.self, forKey: .date_of_birth_capture_convert)
            self = .date_of_birth_capture_convert(dob)
        case .project_apply_start:
            let source = try container.decode(AppSource.self, forKey: .project_apply_start)
            self = .project_apply_start(source)
        case .project_apply_cancel:
            let source = try container.decode(AppSource.self, forKey: .project_apply_cancel)
            self = .project_apply_cancel(source)
        case .project_apply_convert:
            let source = try container.decode(AppSource.self, forKey: .project_apply_convert)
            self = .project_apply_convert(source)
        case .placement_funnel_start:
            let source = try container.decode(AppSource.self, forKey: .placement_funnel_start)
            self = .placement_funnel_start(source)
        case .placement_funnel_convert:
            let source = try container.decode(AppSource.self, forKey: .placement_funnel_convert)
            self = .placement_funnel_convert(source)
        case .placement_funnel_cancel:
            let source = try container.decode(AppSource.self, forKey: .placement_funnel_cancel)
            self = .placement_funnel_cancel(source)
        case .letter_start:
            self = .letter_start
        case .letter_viewed:
            let isComplete = try container.decode(Bool.self, forKey: .letter_viewed)
            self = .letter_viewed(isComplete: isComplete)
        case .letter_editor_opened:
            self = .letter_editor_opened
        case .letter_editor_closed:
            self = .letter_editor_closed
        case .question_opened:
            let type = try container.decode(PicklistType.self, forKey: .question_opened)
            self = .question_opened(type)
        case .question_closed:
            var nestedContainer = try container.nestedUnkeyedContainer(forKey: .question_closed)
            let type = try nestedContainer.decode(PicklistType.self)
            let isAnswered = try nestedContainer.decode(Bool.self)
            self = .question_closed(type, isAnswered: isAnswered)
        case .letter_convert:
            self = .letter_convert
        case .letter_cancel:
            let isComplete = try container.decode(Bool.self, forKey: .letter_cancel)
            self = .letter_cancel(isComplete: isComplete)
        case .document_upload_start:
            self = .document_upload_start
        case .document_upload_document_selected:
            self = .document_upload_document_selected
        case .document_upload_convert:
            self = .document_upload_convert
        case .document_upload_skip:
            self = .document_upload_skip
        case .offer_accept:
            self = .offer_accept
        case .offer_decline:
            let reason = try container.decode(String.self, forKey: .offer_decline)
            self = .offer_decline(reason: reason)
        case .company_hosts_page_view:
            let source = try container.decode(AppSource.self, forKey: .company_hosts_page_view)
            self = .company_hosts_page_view(source)
        case .company_hosts_page_dismiss:
            let source = try container.decode(AppSource.self, forKey: .company_hosts_page_dismiss)
            self = .company_hosts_page_dismiss(source)
        case .project_page_view:
            let source = try container.decode(AppSource.self, forKey: .project_page_view)
            self = .project_page_view(source)
        case .project_page_dismiss:
            let source = try container.decode(AppSource.self, forKey: .project_page_dismiss)
            self = .project_page_dismiss(source)
        case .application_page_view:
            let source = try container.decode(AppSource.self, forKey: .application_page_view)
            self = .application_page_view(source)
        case .application_page_dismiss:
            let source = try container.decode(AppSource.self, forKey: .application_page_dismiss)
            self = .application_page_dismiss(source)
        case .offer_page_view:
            let source = try container.decode(AppSource.self, forKey: .offer_page_view)
            self = .offer_page_view(source)
        case .offer_page_dismiss:
            let source = try container.decode(AppSource.self, forKey: .offer_page_dismiss)
            self = .offer_page_dismiss(source)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
//        case .appStart:
//            try container.encode(true, forKey: .appStart)
//        case .application(source: let source):
//            try container.encode(source, forKey: .application)
//        case .search(term: let term, source: let source):
//            var nestedContainer = container.nestedUnkeyedContainer(forKey: .search)
//            try nestedContainer.encode(term)
//            try nestedContainer.encode(source)
        case .first_use:
            try container.encode(true, forKey: .first_use)
        case .app_open:
            try container.encode(true, forKey: .app_open)
        case .onboarding_start:
            try container.encode(true, forKey: .onboarding_start)
        case .onboarding_cancel:
            try container.encode(true, forKey: .onboarding_cancel)
        case .onboarding_tap_sign_in:
            try container.encode(true, forKey: .onboarding_tap_sign_in)
        case .onboarding_tap_just_get_started:
            try container.encode(true, forKey: .onboarding_tap_just_get_started)
        case .onboarding_convert:
            try container.encode(true, forKey: .onboarding_convert)
        case .tab_tap(tabName: let tabName):
            try container.encode(tabName, forKey: .tab_tap)
        case .register_user_start:
            try container.encode(true, forKey: .register_user_start)
        case .register_user_cancel:
            try container.encode(true, forKey: .register_user_cancel)
        case .register_user_convert:
            try container.encode(true, forKey: .register_user_convert)
        case .search_home_typeahead_start:
            try container.encode(true, forKey: .search_home_typeahead_start)
        case .search_home_selected_typeahead_item:
            try container.encode(true, forKey: .search_home_selected_typeahead_item)
        case .search_home_cancel_typeahead:
            try container.encode(true, forKey: .search_home_cancel_typeahead)
        case .search_home_perform_full(search: let search):
            try container.encode(search, forKey: .search_home_perform_full)
        case .search_home_perform_popular(search: let search):
            try container.encode(search, forKey: .search_home_perform_popular)
        case .search_home_apply_filters(search: let search):
            try container.encode(search, forKey: .search_home_apply_filters)
        case .allow_notifications_start:
            try container.encode(true, forKey: .allow_notifications_start)
        case .allow_notifications_cancel:
            try container.encode(true, forKey: .allow_notifications_cancel)
        case .allow_notifications_convert:
            try container.encode(true, forKey: .allow_notifications_convert)
        case .recommendation_deeplink_start:
            try container.encode(true, forKey: .recommendation_deeplink_start)
        case .recommendation_deeplink_cancel:
            try container.encode(true, forKey: .recommendation_deeplink_cancel)
        case .recommendation_deeplink_convert:
            try container.encode(true, forKey: .recommendation_deeplink_convert)
        case .placement_deeplink_start:
            try container.encode(true, forKey: .placement_deeplink_start)
        case .placement_deeplink_cancel:
            try container.encode(true, forKey: .placement_deeplink_cancel)
        case .placement_deeplink_convert:
            try container.encode(true, forKey: .placement_deeplink_convert)
        case .recommendation_pushnotification_start:
            try container.encode(true, forKey: .recommendation_pushnotification_start)
        case .recommendation_pushnotification_cancel:
            try container.encode(true, forKey: .recommendation_pushnotification_cancel)
        case .recommendation_pushnotification_convert:
            try container.encode(true, forKey: .recommendation_pushnotification_convert)
        case .passive_apply_start(let source):
            try container.encode(source, forKey: .passive_apply_start)
        case .passive_apply_cancel(let source):
            try container.encode(source, forKey: .passive_apply_cancel)
        case .passive_apply_convert(let source):
            try container.encode(source, forKey: .passive_apply_convert)
        case .date_of_birth_capture_start:
            try container.encode(true, forKey: .date_of_birth_capture_start)
        case .date_of_birth_capture_cancel:
            try container.encode(true, forKey: .date_of_birth_capture_cancel)
        case .date_of_birth_capture_convert(let dob):
            try container.encode(dob, forKey: .date_of_birth_capture_convert)
        case .project_apply_start(let source):
            try container.encode(source, forKey: .project_apply_start)
        case .project_apply_cancel(let source):
            try container.encode(source, forKey: .project_apply_cancel)
        case .project_apply_convert(let source):
            try container.encode(source, forKey: .project_apply_convert)
        case .placement_funnel_start(let source):
            try container.encode(source, forKey: .placement_funnel_start)
        case .placement_funnel_convert(let source):
            try container.encode(source, forKey: .placement_funnel_convert)
        case .placement_funnel_cancel(let source):
            try container.encode(source, forKey: .placement_funnel_cancel)
        case .letter_start:
            try container.encode(true, forKey: .letter_start)
        case .letter_viewed(isComplete: let isComplete):
            try container.encode(isComplete, forKey: .letter_viewed)
        case .letter_editor_opened:
            try container.encode(true, forKey: .letter_editor_opened)
        case .letter_editor_closed:
            try container.encode(true, forKey: .letter_editor_closed)
        case .question_opened(let picklistType):
            try container.encode(picklistType, forKey: .question_opened)
        case .question_closed(let picklistType, isAnswered: let isAnswered):
            var nestedContainer = container.nestedUnkeyedContainer(forKey: .question_closed)
            try nestedContainer.encode(picklistType)
            try nestedContainer.encode(isAnswered)
        case .letter_convert:
            try container.encode(true, forKey: .letter_convert)
        case .letter_cancel(isComplete: let isComplete):
            try container.encode(isComplete, forKey: .letter_cancel)
        case .document_upload_start:
            try container.encode(true, forKey: .document_upload_start)
        case .document_upload_document_selected:
            try container.encode(true, forKey: .document_upload_document_selected)
        case .document_upload_convert:
            try container.encode(true, forKey: .document_upload_convert)
        case .document_upload_skip:
            try container.encode(true, forKey: .document_upload_skip)
        case .offer_accept:
            try container.encode(true, forKey: .offer_accept)
        case .offer_decline(reason: let reason):
            try container.encode(reason, forKey: .offer_decline)
        case .company_hosts_page_view(let source):
            try container.encode(source, forKey: .company_hosts_page_view)
        case .company_hosts_page_dismiss(let source):
            try container.encode(source, forKey: .company_hosts_page_dismiss)
        case .project_page_view(let source):
            try container.encode(source, forKey: .project_page_view)
        case .project_page_dismiss(let source):
            try container.encode(source, forKey: .project_page_dismiss)
        case .application_page_view(let source):
            try container.encode(source, forKey: .application_page_view)
        case .application_page_dismiss(let source):
            try container.encode(source, forKey: .application_page_dismiss)
        case .offer_page_view(let source):
            try container.encode(source, forKey: .offer_page_view)
        case .offer_page_dismiss(let source):
            try container.encode(source, forKey: .offer_page_dismiss)
        }
    }
}

