//
//  TimelineEntryTableViewCell.swift
//  f4s-workexperience
//
//  Created by Sergiu Simon on 04/01/17.
//  Copyright © 2017 freshbyte. All rights reserved.
//

import UIKit

class TimelineEntryTableViewCell: UITableViewCell {

    @IBOutlet weak var companyImageView: UIImageView!
    @IBOutlet weak var companyTitleLabel: UILabel!
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var dateTimeLatestMessageLabel: UILabel!
    @IBOutlet weak var unreadMessageDotView: UIView!
    
    var presenter: TimelineCellViewPresenter? {
        didSet {
            presenter?.present()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        unreadMessageDotView.backgroundColor = UIColor.red
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
