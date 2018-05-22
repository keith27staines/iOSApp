//
//  F4SUrlDescriptorTableViewCell.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 22/05/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class F4SUrlDescriptorTableViewCell: UITableViewCell {
    
    @IBOutlet var leftImage: UIImageView!
    @ IBOutlet var label: UILabel!
    @IBOutlet var underliningView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    let defaultText = "Tap to add link to your "
    
    var deleteButtonWasPressed : ((F4SUrlDescriptorTableViewCell) -> Void)? = nil
    
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
            if let descriptor = documentUrlDescriptor {
                label.text = displayText(descriptor: descriptor)
                self.deleteButton.isHidden = (descriptor.url == nil)
                if !descriptor.urlString.isEmpty {
                    self.label.textColor = UIColor.black
                    self.leftImage.image = #imageLiteral(resourceName: "blackLinkURL")
                    if descriptor.isValidUrl {
                        underliningView.backgroundColor = UIColor.green
                    } else {
                        underliningView.backgroundColor = UIColor.orange
                    }
                }
            }
        }
    }
    
    func displayText(descriptor: F4SDocumentUrlDescriptor) -> String {
        if descriptor.isValidUrl {
            return descriptor.documentUrl.url
        }
        return defaultText + descriptor.docType.title
        
    }
    
    func requiredHeight(numberOfLines: Int) -> CGFloat {
        let padding = numberOfLines == 0 ? CGFloat(10) : CGFloat(20)
        let oldNumber = label.numberOfLines
        label.numberOfLines = numberOfLines
        let size = label.sizeThatFits(label.bounds.size)
        label.numberOfLines = oldNumber
        return max(ceil(size.height)+padding,40)
    }
    
}

