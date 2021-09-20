//
//  DateSelectorPresenter.swift
//  WorkfinderInterviews
//
//  Created by Keith on 16/07/2021.
//

import Foundation
import UIKit
import WorkfinderCommon
import WorkfinderServices

class DateSelectorDatasource: NSObject {
    
    typealias Interview = InterviewJson
    typealias InterviewDate = Interview.InterviewDateJson
    
    var selectionDidChange: (() -> Void)?
    
    var interviewDates: [InterviewDate] { interview.interviewDates ?? [] }

    private var interview: Interview
    var dateString: String { "Cell with index \(selectedRowIndexPath?.row ?? -1)" }
    var selectedRowIndexPath: IndexPath?
    
    var selectedInterviewDate: InterviewJson.InterviewDateJson? {
        guard let selectedIndexPath = selectedRowIndexPath else { return nil }
        return interviewDates[selectedIndexPath.row]
    }
    
    init(interview: Interview, selectionDidChange: @escaping () -> Void) {
        self.interview = interview
        self.selectionDidChange = selectionDidChange
        super.init()
    }
}

extension DateSelectorDatasource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        interviewDates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: DateCell.reuseIdentifier) as? DateCell
        else {
            return UITableViewCell()
        }
        let dateString = "date string"
        let isSelected = selectedRowIndexPath == indexPath
        cell.configure(dateString, isSelected: isSelected)
        return cell
    }
}

extension DateSelectorDatasource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var affectedIndexPaths = [indexPath]
        if indexPath == selectedRowIndexPath {
            selectedRowIndexPath = nil
        } else {
            if let currentlySelectedIndexPath = selectedRowIndexPath {
                affectedIndexPaths.append(currentlySelectedIndexPath)
            }
            selectedRowIndexPath = indexPath
        }
        tableView.reloadRows(at: affectedIndexPaths, with: .automatic)
        selectionDidChange?()
    }

}

