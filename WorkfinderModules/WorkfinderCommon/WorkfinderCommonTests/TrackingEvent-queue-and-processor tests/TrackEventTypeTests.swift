//
//  TrackEventTypeTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Staines on 26/01/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import XCTest
import WorkfinderCommon

class TrackEventTypeTests: XCTestCase {
    let date = Date()
    let source = AppSource.homeTabRecentRolesList
    lazy var originalEvents: [TrackingEventType] = [
        .allow_notifications_cancel,
        .allow_notifications_start,
        .allow_notifications_convert,
        .app_open,
        .application_page_dismiss(source),
        .application_page_view(source),
        .company_hosts_page_dismiss(source),
        .company_hosts_page_view(source),
        .date_of_birth_capture_cancel,
        .date_of_birth_capture_start,
        .date_of_birth_capture_convert(date),
        .document_upload_convert,
        .document_upload_document_selected,
        .document_upload_skip,
        .document_upload_start,
        .first_use,
        .letter_cancel(isComplete: true),
        .letter_convert,
        .letter_start,
        .letter_editor_closed,
        .letter_editor_opened,
        .letter_viewed(isComplete: true),
        .offer_accept,
        .offer_decline(reason: "reason"),
        .offer_page_dismiss(source),
        .offer_page_view(source),
        .onboarding_cancel,
        .onboarding_convert,
        .onboarding_start,
        .onboarding_tap_sign_in,
        .onboarding_tap_just_get_started,
        .passive_apply_cancel(source),
        .passive_apply_start(source),
        .passive_apply_convert(source),
        .placement_deeplink_start,
        .placement_deeplink_cancel,
        .placement_deeplink_convert,
        .placement_funnel_start(source),
        .placement_funnel_cancel(source),
        .placement_funnel_convert(source),
        .project_apply_cancel(source),
        .project_apply_convert(source),
        .project_apply_start(source),
        .project_page_view(source),
        .project_page_dismiss(source),
        .question_opened(.attributes),
        .question_closed(.attributes, isAnswered: true),
        .recommendation_deeplink_start,
        .recommendation_deeplink_cancel,
        .recommendation_deeplink_convert,
        .recommendation_pushnotification_start,
        .recommendation_pushnotification_cancel,
        .recommendation_pushnotification_convert,
        .register_user_start,
        .register_user_cancel,
        .register_user_convert,
        .search_home_apply_filters(search: "search"),
        .search_home_typeahead_start,
        .search_home_cancel_typeahead,
        .search_home_perform_full(search: "search"),
        .search_home_perform_popular(search: "search"),
        .search_home_selected_typeahead_item,
        .tab_tap(tabName: "tab name"),
    ]
    
    func test_code_decode_equatable() throws {
        let data = try JSONEncoder().encode(originalEvents)
        let recoveredEvents = try JSONDecoder().decode([TrackingEventType].self, from: data)
        XCTAssertEqual(originalEvents, recoveredEvents)
        XCTAssertEqual(originalEvents.count, 63)
    }

}
