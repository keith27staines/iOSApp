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
    
    public override func viewWillAppear(_ animated: Bool) {
        styleButton(button: amButton)
        styleButton(button: pmButton)
        styleButton(button: ampmButton)
    }
    
    func styleButton(button: UIButton) {
        let selectedBackgroundColor = skin?.primaryButtonSkin.backgroundColor.uiColor ?? UIColor.white
        let deselectedBackgroundColor = RGBA.white.uiColor
        let selectedText = RGBA.white.uiColor
        let deselectedText = RGBA.lightGray.uiColor
        button.setBackgroundColor(color: selectedBackgroundColor, forUIControlState: .selected)
        button.setBackgroundColor(color: deselectedBackgroundColor, forUIControlState: .normal)
        button.setTitleColor(selectedText, for: .selected)
        button.setTitleColor(deselectedText, for: .normal)
    }
    
    
    public var selectedHoursType: F4SHoursType = .all {
        didSet {
            amButton.isSelected = false
            pmButton.isSelected = false
            ampmButton.isSelected = false
            
            switch selectedHoursType {
            case .am:
                amButton.isSelected = true
            case .pm:
                pmButton.isSelected = true
            case .all:
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
        selectedHoursType = .all
        delegate?.hoursPicker(self, hoursType: .all)
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
