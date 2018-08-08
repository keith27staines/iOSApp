//
//  F4SInviteButtonsTableViewCell.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 25/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class F4SInviteButtonsTableViewCell: UITableViewCell {
    @IBOutlet weak var introductoryText: UILabel!
    @IBOutlet weak var shareText: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var primaryButton: UIButton!
    @IBOutlet var secondaryButton: UIButton!
    
    @IBAction func primaryButtonTappedOffer(_ sender: Any) {
        primaryAction?()
    }
    
    @IBAction func secondaryButtonTapped(_ sender: Any) {
        secondaryAction?()
    }
    
    @IBAction func shareAction(_ sender: Any) {
        shareOffer?()
    }
    
    var primaryAction: ( ()->())?
    var secondaryAction: (()->())?
    var shareOffer: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    
}
