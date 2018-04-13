//
//  F4SFeatureSwitchTableViewCell.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 08/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class F4SFeatureSwitchTableViewCell: UITableViewCell {

    var feature: F4SFeature? {
        didSet {
            if let feature = feature {
                featureName.text = feature.name
                onSwitch.isOn = feature.isOn
            }
        }
    }
    
    @IBOutlet weak var featureName: UILabel!
    
    @IBOutlet weak var onSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
