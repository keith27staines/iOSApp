//
//  UrlTableViewCell.swift
//  UrlUploadDemo
//
//  Created by Keith Dev on 16/02/2018.
//  Copyright © 2018 Keith Dev. All rights reserved.
//

import UIKit

class UrlTableViewCell: UITableViewCell {
    
    @IBOutlet var leftImage: UIImageView!
    @ IBOutlet var label: UILabel!
    @IBOutlet var underliningView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    let defaultText = "https://www.linkedin.com/in/yourprofile"
    
    var deleteButtonWasPressed : ((UrlTableViewCell) -> Void)? = nil
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        deleteButtonWasPressed?(self)
    }
    
    var documentUrlDescriptor : F4SDocumentUrlDescriptor? {
        didSet {
            self.label.text = defaultText
            self.label.textColor = UIColor.lightGray
            self.label.numberOfLines = 10
            self.leftImage.image = #imageLiteral(resourceName: "greyLinkURL")
            self.accessoryType = .none
            self.underliningView.backgroundColor = UIColor.orange
            self.deleteButton.isHidden = false
            if let documentUrlDescriptor = documentUrlDescriptor {
                if !documentUrlDescriptor.urlString.isEmpty {
                    self.label.text = displayText(urlString: documentUrlDescriptor.urlString)
                    self.label.textColor = UIColor.black
                    self.leftImage.image = #imageLiteral(resourceName: "blackLinkURL")
                    if documentUrlDescriptor.isValidUrl {
                        underliningView.backgroundColor = UIColor.green
                    } else {
                        underliningView.backgroundColor = UIColor.orange
                    }
                    self.deleteButton.isHidden = false
                }
            }
        }
    }
    
    func displayText(urlString: String) -> String {
        let www = "www."
        let delimiter = "://"
        if let r = urlString.range(of: www) {
            return String(urlString[r.upperBound...])
        } else {
            if let r = urlString.range(of: delimiter) {
               return String(urlString[r.upperBound...])
            }
            return urlString
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func requiredHeight(numberOfLines: Int) -> CGFloat {
        let padding = numberOfLines == 0 ? CGFloat(10) : CGFloat(20)
        let oldNumber = label.numberOfLines
        label.numberOfLines = numberOfLines
        let size = label.sizeThatFits(label.bounds.size)
        label.numberOfLines = oldNumber
        return max(ceil(size.height)+padding,40)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
