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

class DateSelectorPresenter: NSObject {
    
    weak var table: UITableView?
    weak var coordinator: AcceptInviteCoordinatorProtocol?
    
    var invite: InterviewJson? { coordinator?.interview }
    var interviewDates: [InterviewJson.InterviewDateJson] { invite?.interviewDates ?? [] }
    
    init(coordinator: AcceptInviteCoordinatorProtocol) {
        self.coordinator = coordinator
        super.init()
    }
    
    func onViewDidLoad(table: UITableView) {
        self.table = table
        table.register(DateCell.self, forCellReuseIdentifier: DateCell.reuseIdentifier)
        table.dataSource = self
        table.delegate = self
        table.reloadData()
    }
    
}

extension DateSelectorPresenter: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        interviewDates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: DateCell.reuseIdentifier) as? DateCell,
            let interviewDate = invite?.interviewDates?[indexPath.row] else {
            return UITableViewCell()
        }
        let datestring = interviewDate.dateTime ?? ""
        let timestring = interviewDate.timeString ?? ""
        cell.configureWithDateString(datestring, timeString: timestring)
        let currentlySelectedDate = coordinator?.selectedInterviewDate
        let isCurrentlySelected = interviewDate == currentlySelectedDate
        cell.accessoryType = isCurrentlySelected ? .checkmark : .none
        return cell
    }
}

extension DateSelectorPresenter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let interviewDate = invite?.interviewDates?[indexPath.row] else { return }
        let currentlySelectedDate = coordinator?.selectedInterviewDate
        let isCurrentlySelected = interviewDate == currentlySelectedDate
        coordinator?.selectedInterviewDate = isCurrentlySelected ? nil : interviewDate
        tableView.reloadData()
    }
}

class DateCell: UITableViewCell {
    static let reuseIdentifier = "DateCell"
    
    func configureWithDateString(_ dateString: String, timeString: String) {
        guard let date = Date.dateFromRfc3339(string: dateString) else {
            clear()
            return
        }
        let df = DateFormatter()
        df.dateStyle = .long
        df.timeStyle = .none
        let tf = DateFormatter()
        tf.dateStyle = .none
        tf.timeStyle = .short
        textLabel?.text = df.string(from: date)
        detailTextLabel?.text = tf.string(from: date)
    }
    
    func clear() {
        textLabel?.text = ""
        detailTextLabel?.text = ""
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

