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
                string: company.name, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: Style.largeTextSize, weight: UIFont.Weight.semibold), NSAttributedStringKey.foregroundColor: UIColor.black])
            
            self.industryLabel.attributedText = NSAttributedString(
                string: company.industry, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: Style.smallerMediumTextSize, weight: UIFont.Weight.light), NSAttributedStringKey.foregroundColor: UIColor.black])
            
            if !company.logoUrl.isEmpty, let url = NSURL(string: company.logoUrl) {
                ImageService.sharedInstance.getImage(url: url, completed: {
                    succeeded, image in
                    DispatchQueue.main.async { [weak self] in
                        if succeeded && image != nil {
                            self?.logo.image = image!
                        } else {
                            self?.logo.image = UIImage(named: "DefaultLogo")
                        }
                    }
                })
            } else {
                self.logo.image = UIImage(named: "DefaultLogo")
            }
        }
    }

    @IBOutlet weak var industryLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var logo: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
