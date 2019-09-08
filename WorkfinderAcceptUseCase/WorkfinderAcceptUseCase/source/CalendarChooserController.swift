//
//  CalendarChooserController.swift
//  CalendarTest
//
//  Created by Keith Dev on 07/08/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit
import EventKit
import WorkfinderCommon
import WorkfinderUI

protocol CalendarChooserControllerDelegate : class {
    func calendarChooserDidCancel(_ calendardChooser: CalendarChooserController)
    func calendarChooserDidFinish(_ calendardChooser: CalendarChooserController, calendar: EKCalendar)
}

class CalendarChooserController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: CalendarChooserControllerDelegate? = nil
    var selectedCalendar: EKCalendar? = nil
    var calendars = [EKCalendar]()
    let eventStore = EKEventStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adjustNavigationBar()
        applyStyle()
        doneButton.isEnabled = false
        eventStore.requestAccess(to: .event) { (success, error) in
            self.calendars = self.eventStore.calendars(for: EKEntityType.event).sorted() { (cal1, cal2) -> Bool in
                return cal1.title < cal2.title
                }.filter({ (cal) -> Bool in
                    return cal.allowsContentModifications
                })
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func adjustNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = NSLocalizedString("Choose calendar", comment: "")
    }
    
    func applyStyle() {
        styleNavigationController()
        let skinner = Skinner()
        skinner.apply(buttonSkin: skin?.primaryButtonSkin, to: doneButton)
        skinner.apply(buttonSkin: skin?.secondaryButtonSkin, to: cancelButton)
    }
    
    @IBAction func cancelButtonTapped(sender: Any) {
        selectedCalendar = nil
        delegate?.calendarChooserDidCancel(self)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(sender: Any) {
        guard let calendar = selectedCalendar else {
            return
        }
        delegate?.calendarChooserDidFinish(self, calendar: calendar)
        dismiss(animated: true, completion: nil)
    }


    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendars.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
        cell.textLabel?.text = calendars[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        doneButton.isEnabled = true
        selectedCalendar = calendars[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        for row in 0..<calendars.count {
            let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0))
            cell?.accessoryType = .none
        }
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        doneButtonTapped(sender: self)
    }

}
