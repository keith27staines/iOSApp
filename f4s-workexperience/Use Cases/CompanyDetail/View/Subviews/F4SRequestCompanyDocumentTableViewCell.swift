//
//  F4SRequestCompanyDocumentTableViewCell.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 01/05/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class F4SRequestCompanyDocumentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var buttonBackgroundView: UIView!
    @IBOutlet weak var buttonLabel: UILabel!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    var companyDocument: F4SCompanyDocument? = nil {
        didSet {
            guard let document = companyDocument, let state = companyDocument?.state else {
                buttonLabel.text = ""
                buttonBackgroundView.backgroundColor = UIColor.white
                return
            }
            
            switch state {
            case .requested:
                buttonLabel.text = "\(document.name) has been requested"
                buttonBackgroundView.backgroundColor = UIColor(red: 72, green: 38, blue: 127)
                buttonBackgroundView.alpha = 0.5
            case .unrequested:
                buttonLabel.text = "Request \(document.name)"
                buttonBackgroundView.backgroundColor = UIColor(red: 72, green: 38, blue: 127)
                buttonBackgroundView.alpha = 1.0
            default:
                buttonLabel.text = ""
                buttonBackgroundView.backgroundColor = UIColor.white
            }
            buttonLabel.textColor = UIColor.white
            buttonLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            buttonLabel.adjustsFontSizeToFitWidth = true
            buttonLabel.minimumScaleFactor = 0.5
        }
    }
}
