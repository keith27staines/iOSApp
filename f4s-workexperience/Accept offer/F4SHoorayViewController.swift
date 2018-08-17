//
//  F4SHoorayViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 24/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit
import EventKit

class F4SHoorayViewController: UIViewController {
    @IBOutlet weak var companyHeaderView: F4SCompanyHeaderViewWithLogo!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var hoorayLabel: UILabel!
    @IBOutlet weak var placementConfirmedLabel: UILabel!
    @IBOutlet weak var informationLabel: UILabel!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var addToCalendarButton: UIButton!

    @IBOutlet weak var shareImageView: UIImageView!
    let eventStore = EKEventStore()
    var accept: AcceptOfferContext!
    
    @IBAction func shareTapped(_ sender: Any) {
        accept.presentShare(from: self, sourceView: shareImageView)
    }
    var startDate: Date?
    var endDate: Date?
    
    func isEventInformationComplete() -> Bool {
        guard
            let startDateString = accept.placement.duration?.start_date,
            let startDate = F4SDateHelper.yyyyMMDD(string: startDateString),
            let endDateString = accept.placement.duration?.end_date,
            let endDate = F4SDateHelper.yyyyMMDD(string: endDateString) else {
                insufficientDateInformation()
                return false
        }
        self.startDate = startDate
        self.endDate = endDate
        return true
    }
    
    @IBAction func showCalendarChooser(_ sender: Any) {
        guard isEventInformationComplete() else { return }
        addToCalendarButton.isEnabled = false
        checkCalendarAuthorizationStatus(completion: { allowed in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                guard allowed else {
                    strongSelf.addToCalendarButton.isEnabled = true
                    self?.needsPermission()
                    return
                }
                strongSelf.performSegue(withIdentifier: "showCalendarChooser", sender: self)
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CalendarChooserController {
            vc.delegate = self
        }
    }
    
    func insufficientDateInformation() {
        print("Insufficient information to write to calendar")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyle()
        addToCalendarButton.isEnabled = isEventInformationComplete()
    }
    
    func applyStyle() {
        companyHeaderView.fillTop = false
        companyHeaderView.fillColor = UIColor.white
        companyHeaderView.leftDrop = 1.0
        companyHeaderView.rightDrop = 0.3
        companyHeaderView.backgroundColor = UIColor.clear
        companyNameLabel.text = accept.company.name.stripCompanySuffix()
        companyHeaderView.icon = accept.companyLogo
        let skinner = Skinner()
        skinner.apply(buttonSkin: skin?.primaryButtonSkin, to: doneButton)
        skinner.apply(buttonSkin: skin?.secondaryButtonSkin, to: addToCalendarButton)
        hoorayLabel.textColor = RGBA.workfinderPurple.uiColor
        placementConfirmedLabel.textColor = RGBA.workfinderPurple.uiColor
    }
}


// MARK:- Calendar event writing support
extension F4SHoorayViewController {
    func checkCalendarAuthorizationStatus(completion: @escaping (Bool)->()) {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            // This happens on first-run when the system will ask permission from the user
            requestAccessToCalendar(completion: completion)
        case EKAuthorizationStatus.authorized:
            completion(true)
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            // The user will need to go to settings to allow us to write to calendar
            completion(false)
        }
    }
    
    func requestAccessToCalendar(completion: @escaping (Bool)->()) {
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: EKEntityType.event, completion: { [weak self]
            (accessGranted: Bool, error: Error?) in
            
            if accessGranted == true {
                DispatchQueue.main.async(execute: {
                    completion(true)
                })
            } else {
                DispatchQueue.main.async(execute: {
                    self?.needsPermission()
                })
            }
        })
    }
    
    func needsPermission() {
        let title = NSLocalizedString("Worfkinder doesn't have access to your calendar", comment: "")
        let message = NSLocalizedString("If you want Workfinder to record your  placement details in your calendar please go to settings and give permission", comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.addToCalendarButton.isHidden = false
            self.addToCalendarButton.isEnabled = true
        }
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
            let openSettingsUrl = URL(string: UIApplicationOpenSettingsURLString)
            UIApplication.shared.open(openSettingsUrl!)
        }
        alert.addAction(cancelAction)
        alert.addAction(settingsAction)
        present(alert, animated: true)
    }
}

// MARK:- CalendarChooserDelegate
extension F4SHoorayViewController : CalendarChooserControllerDelegate {
    func calendarChooserDidCancel(_ calendardChooser: CalendarChooserController) {
        addToCalendarButton.isHidden = false
        addToCalendarButton.isEnabled = true
        navigationController?.popViewController(animated: true)
    }
    
    func calendarChooserDidFinish(_ calendardChooser: CalendarChooserController, calendar: EKCalendar) {
        let event = EKEvent(eventStore: eventStore)
        event.calendar = eventStore.calendar(withIdentifier: calendar.calendarIdentifier)
        event.title = "Workfinder placement at \(accept.company.name.stripCompanySuffix())"
        event.notes = accept.description
        event.startDate = startDate!
        event.endDate = endDate!
        event.isAllDay = true
        do {
            MessageHandler.sharedInstance.showLoadingOverlay(view)
            try eventStore.save(event, span: .thisEvent, commit: true)
            MessageHandler.sharedInstance.hideLoadingOverlay()
        } catch {
            MessageHandler.sharedInstance.hideLoadingOverlay()
            let alert = UIAlertController(title: "Workfinder could not save your placement details to your calendar", message: (error as NSError).localizedDescription, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OKAction)
            present(alert, animated: true, completion: nil)
        }
    }
}



























