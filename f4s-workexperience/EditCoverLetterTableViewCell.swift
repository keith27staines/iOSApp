//
//  CoverLetterTableViewCell.swift
//  f4s-workexperience
//
//  Created by iOS FRB on 11/22/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit

class EditCoverLetterTableViewCell: UITableViewCell {
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var editValueLabel: UILabel!
    @IBOutlet weak var editTextLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
