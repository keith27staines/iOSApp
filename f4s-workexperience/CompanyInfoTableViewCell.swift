//
//  CompanyInfoTableViewCell.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 14/11/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import UIKit

class CompanyInfoTableViewCell: UITableViewCell {
    
    var company: Company! {
        didSet {
            self.companyNameLabel.attributedText = NSAttributedString(
                string: company.name, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.black])
            
            self.industryLabel.attributedText = NSAttributedString(
                string: company.industry, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
            self.starRating.rating = Float(company.rating)
            self.starRating.isHidden = (company.rating == 0) ? true : false
            self.logo.image = UIImage(named: "DefaultLogo")
            if !company.logoUrl.isEmpty, let url = NSURL(string: company.logoUrl) {
                F4SImageService.sharedInstance.getImage(url: url, completion: { [weak self]
                    image in
                    if image != nil {
                        self?.logo.image = image!
                    } else {
                        self?.logo.image = UIImage(named: "DefaultLogo")
                    }
                })
            }
        }
    }

    @IBOutlet weak var industryLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var starRating: StarRatingView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
