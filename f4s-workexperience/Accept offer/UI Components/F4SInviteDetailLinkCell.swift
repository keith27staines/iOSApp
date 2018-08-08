//
//  F4SInviteDetailLinkCell.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 08/08/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class F4SInviteDetailLinkCell: UITableViewCell {

    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var icon: UIImageView!
    
    lazy var linkTextAttributes: [NSAttributedStringKey: Any] = {
        return [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14),
            NSAttributedStringKey.foregroundColor : UIColor.blue,
            NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue
        ]
    }()
    
    @IBAction func buttonTapped(sender: UIButton) {
        guard let detail = detail else { return }
        if detail.isEmail == true, let email = detail.title {
            openEmailComposer(email: email)
            return
        }
        if let url = detail.linkUrl {
            openUrl(url)
        }
    }
    
    func openUrl(_ url: URL) {
        UIApplication.shared.open(url)
    }
    
    func openEmailComposer(email: String) {
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
    
    var detail: F4SPlacementInviteSectionDetails? {
        didSet {
            self.icon.image = detail?.icon
            if let text = detail?.lines?.first {
                let attributeString = NSMutableAttributedString(string: text, attributes: linkTextAttributes)
                self.linkButton.setAttributedTitle(attributeString, for: .normal)
                self.linkButton.setTitle(text, for: .normal)
                self.linkButton.isHidden = false
            } else {
                let attributeString = NSMutableAttributedString(string: "", attributes: linkTextAttributes)
                self.linkButton.setAttributedTitle(attributeString, for: .normal)
                self.linkButton.isHidden = true
            }
        }
    }
}
