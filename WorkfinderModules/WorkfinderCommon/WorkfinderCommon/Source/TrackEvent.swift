

public struct TrackingEvent {
    public let type: TrackingEventType
    public private (set) var additionalProperties: [String: Any] = [:]
    
    public init(type: TrackingEventType) {
        self.init(type: type, additionalProperties: [:])
    }
    
    init(type: TrackingEventType, additionalProperties: [String:Any]) {
        self.type = type
        self.additionalProperties = standardProperties.merging(propertiesFrom(type), uniquingKeysWith: {
            (_,second) in second
        })
    }
    
    func propertiesFrom(_ type: TrackingEventType) -> [String: Any] {
        var properties = [String: Any]()
        switch type {
        
        // cases where the TrackEventType has associated data
        case .tab_tap(let tabName): properties["main_tab"] = tabName
        case .search_home_perform_full(let searchTerm): properties["search_term"] = searchTerm
        case .search_home_perform_popular(let searchTerm): properties["search_term"] = searchTerm
        case .search_home_apply_filters(let filters): properties["search_filters"] = filters
        case .passive_apply_start(let source): properties["source"] = source.rawValue
        case .passive_apply_cancel(let source): properties["source"] = source.rawValue
        case .placement_funnel_start(let source): properties["source"] = source.rawValue
        case .placement_funnel_convert(let source): properties["source"] = source.rawValue
        case .placement_funnel_cancel(let source): properties["source"] = source.rawValue
        case .passive_apply_convert(let source): properties["source"] = source.rawValue
        case .project_apply_start(let source): properties["source"] = source.rawValue
        case .project_apply_cancel(let source): properties["source"] = source.rawValue
        case .project_apply_convert(let source): properties["source"] = source.rawValue
        case .question_opened(let question): properties["question"] = question.title
        case .question_closed(let question, let isAnswered):
            properties["question"] = question.title
            properties["answered"] = isAnswered
        case .date_of_birth_capture_convert(let dob): properties["dob"] = dob
        case .letter_viewed(let isComplete): properties["is_complete"] = isComplete
        case .letter_cancel(let isComplete): properties["is_complete"] = isComplete
            
        case .company_hosts_page_view(let source): properties["source"] = source.rawValue
        case .company_hosts_page_dismiss(let source): properties["source"] = source.rawValue
        case .application_page_view(let source): properties["source"] = source.rawValue
        case .application_page_dismiss(let source): properties["source"] = source.rawValue
        case .project_page_view(let source): properties["source"] = source.rawValue
        case .project_page_dismiss(let source): properties["source"] = source.rawValue
        case .offer_page_view(let source): properties["source"] = source.rawValue
        case .offer_decline(let reason): properties["reason"] = reason
        case .offer_page_dismiss(let source): properties["source"] = source.rawValue
        
        // cases where the TrackEventType does not have associated data
        case .first_use: break
        case .app_open: break
        case .onboarding_start: break
        case .onboarding_cancel: break
        case .onboarding_tap_sign_in: break
        case .onboarding_tap_just_get_started: break
        case .onboarding_convert: break
        case .register_user_start: break
        case .register_user_cancel: break
        case .register_user_convert: break
        case .allow_notifications_start: break
        case .allow_notifications_cancel: break
        case .allow_notifications_convert: break
        case .interviewInvite_deeplink_start: break
        case .interviewInvite_deeplink_cancel: break
        case .interviewInvite_deeplink_convert: break
        case .recommendation_deeplink_start: break
        case .recommendation_deeplink_cancel: break
        case .recommendation_deeplink_convert: break
        case .nps_deeplink_start: break
        case .nps_deeplink_cancel: break
        case .nps_deeplink_convert: break
        case .placement_deeplink_start: break
        case .placement_deeplink_cancel: break
        case .placement_deeplink_convert: break
        case .projects_deeplink_start: break
        case .projects_deeplink_cancel: break
        case .projects_deeplink_convert: break
        case .recommendation_pushnotification_start: break
        case .recommendation_pushnotification_cancel: break
        case .recommendation_pushnotification_convert: break
        case .letter_start: break
        case .letter_editor_opened: break
        case .letter_editor_closed: break
        case .letter_convert: break
        case .offer_accept: break
        case .search_home_typeahead_start: break
        case .search_home_cancel_typeahead: break
        case .search_home_selected_typeahead_item: break
        case .date_of_birth_capture_start: break
        case .date_of_birth_capture_cancel: break
        case .document_upload_start: break
        case .document_upload_skip: break
        case .document_upload_document_selected: break
        case .document_upload_convert: break
        case .students_dashboard_deeplink_start: break
        case .students_dashboard_deeplink_cancel: break
        case .students_dashboard_deeplink_convert: break
        }
        return properties
    }
    
    var standardProperties: [String: Any] {
        var properties = [String: Any]()
        properties["user_id"] = UserRepository().loadUser().uuid
        properties["device_id"] = UIDevice.current.identifierForVendor?.uuidString
        return properties
    }
    
}
