//
//  CalendarWriter.swift
//  WorkfinderCommon
//
//  Created by Keith on 16/07/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import Foundation
import EventKit

public class CalendarAccess {
    public static func calendarAccessStatus() -> EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: .event)
    }

    public static func addEventToCalendar(
        title: String,
        description: String?,
        startDate: Date,
        endDate: Date,
        completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil
    ) {
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            guard granted && error == nil else { return }
            let event = EKEvent(eventStore: eventStore)
            event.title = title
            event.startDate = startDate
            event.endDate = endDate
            event.notes = description
            event.calendar = eventStore.defaultCalendarForNewEvents
            do {
                try eventStore.save(event, span: .thisEvent)
            } catch let error as NSError {
                completion?(false, error)
                return
            }
            completion?(true, nil)
        })
    }
}



