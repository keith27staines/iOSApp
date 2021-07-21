//
//  InterviewInvite.swift
//  WorkfinderInterviews
//
//  Created by Keith on 15/07/2021.
//

import Foundation

public struct InterviewInvite: Codable {
    public var id: String?
    public var projectId: String?
    public var possibleDates: [String]? = []
    public var selectedDateIndex: Int?
    public var selectedDate: String? {
        guard let index = selectedDateIndex, let dates = possibleDates else { return nil }
        return dates[index]
    }
}
