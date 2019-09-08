//
//  F4SInviteButtonsTableViewCell.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 25/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI

public class F4SInviteButtonsTableViewCell: UITableViewCell {
    @IBOutlet weak public var introductoryText: UILabel!
    @IBOutlet weak public var shareText: UILabel!
    @IBOutlet weak public var shareButton: UIButton!
    @IBOutlet weak public var primaryButton: UIButton!
    @IBOutlet public var secondaryButton: UIButton!
    
    @IBAction func primaryButtonTappedOffer(_ sender: Any) {
        primaryAction?()
    }
    
    @IBAction func secondaryButtonTapped(_ sender: Any) {
        secondaryAction?()
    }
    
    @IBAction func shareAction(_ sender: Any) {
        shareOffer?()
    }
    
    public var primaryAction: ( ()->())?
    public var secondaryAction: (()->())?
    public var shareOffer: (()->())?
    
    public func applyStyle() {
        let skinner = Skinner()
        skinner.apply(buttonSkin: skin?.primaryButtonSkin, to: primaryButton)
        skinner.apply(buttonSkin: skin?.secondaryButtonSkin, to: secondaryButton)
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    
}
