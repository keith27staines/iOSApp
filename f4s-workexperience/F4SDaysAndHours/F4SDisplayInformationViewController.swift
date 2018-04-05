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

public enum F4SDisplayInformationType {
    case daysAndHoursViewController
}

class F4SDisplayInformationViewController: UIViewController {
    
    var type: F4SDisplayInformationType!
    var delegate: F4SDisplayInformationViewControllerDelegate!
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        textView.scrollRangeToVisible(NSRange(location:0, length:0))
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
