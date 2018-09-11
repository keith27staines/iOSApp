//
//  SwitchTableViewCell.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 04/08/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

protocol SwitchTableViewCellDelegate : class {
    func switchCellDidSwitch(_ cell: SwitchTableViewCell, didSwitch on: Bool)
}

class SwitchTableViewCell: UITableViewCell {
    weak var delegate: SwitchTableViewCellDelegate? = nil
    @IBOutlet var onOrOff: UISwitch!
    @IBOutlet var label: UILabel!
    @IBAction func documentRequestStateChanged(_ sender: UISwitch) {
        delegate?.switchCellDidSwitch(self, didSwitch: sender.isOn)
    }
    
    var document: F4SCompanyDocument? {
        didSet {
            self.onOrOff.isOn = document?.userIsRequesting ?? false
            self.label.text = document?.providedNameOrDefaultName ?? "unknown document"
        }
    }

}

class ViewTableViewCell: UITableViewCell {
    @IBOutlet var icon: UIImageView!
    @IBOutlet var label: UILabel!
    var document: F4SCompanyDocument? {
        didSet {
            guard let document = document else {
                self.label.text = ""
                self.icon.image = nil
                self.accessoryType = .none
                self.isUserInteractionEnabled = false
                return
            }
            
            self.label.text = document.providedNameOrDefaultName
            
            if document.isViewable {
                self.accessoryType = .disclosureIndicator
                self.isUserInteractionEnabled = true
                self.icon.image = #imageLiteral(resourceName: "company_doc")  // UIImage(named: "comany_document")
            } else {
                self.icon.image = #imageLiteral(resourceName: "checkBlue")  // UIImage(named: "checkBlue")
                self.accessoryType = .none
                self.isUserInteractionEnabled = false
            }
        }
    }
}
