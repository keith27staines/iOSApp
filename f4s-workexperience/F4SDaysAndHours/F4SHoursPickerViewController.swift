//
//  F4SHoursPickerViewController.swift
//  HoursPicker2
//
//  Created by Keith Dev on 28/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit


public protocol F4SHoursPickerDelegate {
    func hoursPicker(_ picker: F4SHoursPickerViewController, hoursType: F4SHoursType)
    
}

public class F4SHoursPickerViewController: UIViewController {
    
    @IBOutlet weak var amButton: UIButton!
    @IBOutlet weak var pmButton: UIButton!
    @IBOutlet weak var ampmButton: UIButton!
    
    var delegate: F4SHoursPickerDelegate? = nil
    
    public var selectedHoursType: F4SHoursType = .allDay {
        didSet {
            amButton.isSelected = false
            pmButton.isSelected = false
            ampmButton.isSelected = false
            
            switch selectedHoursType {
            case .am:
                amButton.isSelected = true
            case .pm:
                pmButton.isSelected = true
            case .allDay:
                ampmButton.isSelected = true
            case .custom:
                return
            }
        }
    }

    @IBAction func amButtonTapped(_ sender: Any) {
        selectedHoursType = .am
        delegate?.hoursPicker(self, hoursType: .am)
    }
    @IBAction func pmButtonTapped(_ sender: Any) {
        selectedHoursType = .pm
        delegate?.hoursPicker(self, hoursType: .pm)
    }
    @IBAction func ampmButtonTapped(_ sender: Any) {
        selectedHoursType = .allDay
        delegate?.hoursPicker(self, hoursType: .allDay)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.lightGray
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
    }

}
