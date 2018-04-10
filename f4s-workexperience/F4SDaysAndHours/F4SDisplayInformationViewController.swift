//
//  F4SDisplayInformationViewController.swift
//  HoursPicker2
//
//  Created by Keith Dev on 29/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

public protocol F4SDisplayInformationViewControllerDelegate {
    func dismissDisplayInformation()
}

public enum F4SHelpContext {
    case daysAndHoursViewController
    case calendarController
    
    public var shouldShowAutomatically: Bool {
        get {
            return true
        }
        set {
            
        }
    }
    
    public var title: String {
        switch self {
        case .calendarController:
            return NSLocalizedString("Availability help", comment: "")
        case .daysAndHoursViewController:
            return NSLocalizedString("Hours help", comment: "")
        }
    }
    
    public var helpText: String {
        switch self {

        case .daysAndHoursViewController:
            return NSLocalizedString("Select which day(s) of the week you are available for work experience. For each day, you can also adjust the times to be morning, afternoon or the full working day.", comment: "")
            
        case .calendarController:
            return NSLocalizedString("You can select any length of time for your availability, such as the whole summer holidays!\n\nYour availability must start at least six weeks from today, to give you a better chance of being accepted!", comment: "")
        }
    }
}

class F4SDisplayInformationViewController: UIViewController {
    
    var delegate: F4SDisplayInformationViewControllerDelegate!
    var helpContext: F4SHelpContext = F4SHelpContext.daysAndHoursViewController
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var showNextTimeSwitch: UISwitch!
    
    @IBOutlet weak var showNextTimeLabel: UILabel!
    
    @IBOutlet weak var textView: UITextView!
    @IBAction func showNextTimeSwitchChanged(_ sender: Any) {
        
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        delegate.dismissDisplayInformation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.alpha = 0.8
        textView.scrollRangeToVisible(NSRange(location:0, length:0))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        textView.scrollRangeToVisible(NSRange(location:0, length:0))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = helpContext.title
        textView.text = helpContext.helpText
    }

}
