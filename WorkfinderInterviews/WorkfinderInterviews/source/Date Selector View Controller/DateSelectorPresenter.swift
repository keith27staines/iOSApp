//
//  DateSelectorPresenter.swift
//  WorkfinderInterviews
//
//  Created by Keith on 16/07/2021.
//

import Foundation
import UIKit
import WorkfinderCommon

class DateSelectorPresenter: NSObject {
    
    weak var table: UITableView?
    
    let dates: [String]
    var selectedIndex: Int?
    
    init(dates: [String]) {
        self.dates = dates
        super.init()
    }
    
    func onViewDidLoad(table: UITableView) {
        self.table = table
        table.register(DateCell.self, forCellReuseIdentifier: DateCell.reuseIdentifier)
        table.dataSource = self
        table.reloadData()
    }
    
}

extension DateSelectorPresenter: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DateCell.reuseIdentifier) as? DateCell else {
            return UITableViewCell()
        }
        let datestring = dates[indexPath.row]
        cell.configureWithDateString(datestring)
        return cell
    }
}

class DateCell: UITableViewCell {
    static let reuseIdentifier = "DateCell"
    
    func configureWithDateString(_ dateString: String) {
        guard let date = Date.dateFromRfc3339(string: dateString) else {
            clear()
            return
        }
        let df = DateFormatter()
        df.dateStyle = .long
        df.timeStyle = .none
        textLabel?.text = df.string(from: date)
    }
    
    func clear() {
        textLabel?.text = ""
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

