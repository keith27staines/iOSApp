//
//  CalendarChooserController.swift
//  CalendarTest
//
//  Created by Keith Dev on 07/08/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit
import EventKit

protocol CalendarChooserControllerDelegate : class {
    func calendarChooserDidCancel(_ calendardChooser: CalendarChooserController)
    func calendarChooserDidFinish(_ calendardChooser: CalendarChooserController, calendar: EKCalendar)
}

class CalendarChooserController: UITableViewController {
    var delegate: CalendarChooserControllerDelegate? = nil
    var selectedCalendar: EKCalendar? = nil
    var calendars = [EKCalendar]()
    let eventStore = EKEventStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendars = eventStore.calendars(for: EKEntityType.event).sorted() { (cal1, cal2) -> Bool in
            return cal1.title < cal2.title
            }.filter({ (cal) -> Bool in
                return cal.allowsContentModifications
            })
        tableView.reloadData()
        doneButton.isEnabled = false
    }
    
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBAction func cancelButtonTapped(sender: Any) {
        selectedCalendar = nil
        delegate?.calendarChooserDidCancel(self)
    }
    
    @IBAction func doneButtonTapped(sender: Any) {
        guard let calendar = selectedCalendar else {
            return
        }
        delegate?.calendarChooserDidFinish(self, calendar: calendar)
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendars.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
        cell.textLabel?.text = calendars[indexPath.row].title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        doneButton.isEnabled = true
        selectedCalendar = calendars[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        for row in 0..<calendars.count {
            let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0))
            cell?.accessoryType = .none
        }
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
    }

}
