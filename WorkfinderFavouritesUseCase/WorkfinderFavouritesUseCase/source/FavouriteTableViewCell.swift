//
//  FavouriteTableViewCell.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 2/8/17.
//  Copyright © 2017 freshbyte. All rights reserved.
//

import Foundation
import UIKit
import WorkfinderUI

class FavouriteTableViewCell: UITableViewCell {
 
    @IBOutlet weak var companyImageView: F4SSelfLoadingImageView!
    @IBOutlet weak var companyTitleLabel: UILabel!
    @IBOutlet weak var companyIndustryLabel: UILabel!
    @IBOutlet weak var companyStatusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
