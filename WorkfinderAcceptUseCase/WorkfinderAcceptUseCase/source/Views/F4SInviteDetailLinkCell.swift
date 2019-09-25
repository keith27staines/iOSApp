//
//  F4SInviteDetailLinkCell.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 08/08/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

public class F4SInviteDetailLinkCell: UITableViewCell {

    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var icon: UIImageView!
    
    lazy var externalLinkTextAttributes: [NSAttributedString.Key: Any] = {
        var internalAttributes = internalLinkTextAttributes
        internalAttributes[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue
        return internalAttributes
    }()
    
    lazy var internalLinkTextAttributes: [NSAttributedString.Key: Any] = {
        return [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
            NSAttributedString.Key.foregroundColor : UIColor.blue
        ]
    }()
    
    public var buttonAction: ((F4SInviteDetailLinkCell)->())? = nil
    
    func defaultButtonAction(cell: F4SInviteDetailLinkCell) {
        guard let detail = detail else { return }
        if detail.isEmail == true, let email = detail.title {
            openEmailComposer(email: email)
            return
        }
        if let url = detail.linkUrl {
            openUrl(url)
        }
    }
    
    @IBAction func buttonTapped(sender: UIButton) {
        guard let detail = detail else { return }
        guard let buttonAction = buttonAction else {
            if detail.isEmail == true, let email = detail.lines?.first {
                openEmailComposer(email: email)
                return
            }
            if let url = detail.linkUrl {
                openUrl(url)
            }
            return
        }
        buttonAction(self)
    }
    
    func openUrl(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func openEmailComposer(email: String) {
        if let url = URL(string: "mailto:\(email)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    public var textAttributes: [NSAttributedString.Key: Any] {
        return buttonAction == nil ? externalLinkTextAttributes : internalLinkTextAttributes
    }
    
    public var detail: F4SPlacementInviteSectionDetails? {
        didSet {
            self.icon.image = detail?.icon
            if let text = detail?.lines?.first {
                let attributeString = NSMutableAttributedString(string: text, attributes: textAttributes)
                self.linkButton.setAttributedTitle(attributeString, for: .normal)
                self.linkButton.setTitle(text, for: .normal)
                self.linkButton.isHidden = false
            } else {
                let attributeString = NSMutableAttributedString(string: "", attributes: textAttributes)
                self.linkButton.setAttributedTitle(attributeString, for: .normal)
                self.linkButton.isHidden = true
            }
        }
    }
}
