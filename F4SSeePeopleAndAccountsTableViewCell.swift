//
//  F4SSeePeopleAndAccountsTableViewCell.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 01/08/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class F4SSeePeopleAndAccountsTableViewCell: UITableViewCell {

    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    var leftLink: URL? {
        didSet {
            leftButton.isEnabled = leftLink != nil
        }
    }
    
    var rightLink: URL? {
        didSet {
            rightButton.isEnabled = rightLink != nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func leftButtonTapped(_ sender: Any) {
        openUrl(leftLink)
    }
    
    
    @IBAction func rightButtonTapped(_ sender: Any) {
        openUrl(rightLink)
    }
    
    func openUrl(_ url: URL?) {
        guard let url = url else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
}
