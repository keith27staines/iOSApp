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
            self.label.text = document?.nameOrType ?? "unknown document"
        }
    }

}


class ViewTableViewCell: UITableViewCell {
    var document: F4SCompanyDocument? {
        didSet {
            self.label.text = document?.nameOrType ?? "unknown document"
            self.icon.image = UIImage(named: "checkBlue")
            self.accessoryType = .disclosureIndicator
        }
    }
    @IBOutlet var icon: UIImageView!
    @IBOutlet var label: UILabel!
}
