//
//  CompanyDocumentTableViewCell.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 04/08/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class CompanyDocumentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var documentName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
