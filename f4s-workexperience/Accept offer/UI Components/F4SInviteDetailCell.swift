//
//  F4SInviteDetailCell.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 25/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class F4SInviteDetailCell: UITableViewCell {

    @IBOutlet var title: UILabel!
    @IBOutlet var lines: UILabel!
    @IBOutlet var icon: UIImageView!
    
    var detail: F4SPlacementInviteSectionDetails? {
        didSet {
            guard let detail = detail else {
                setTitle(nil)
                setIconImage(nil)
                setlines(lines: nil)
                return
            }
            setTitle(detail.title)
            setIconImage(detail.icon)
            setlines(lines: detail.lines)
        }
    }
    
    private func setlines(lines: [String]?) {
        if lines == nil || lines?.isEmpty == true {
            self.lines.text = ""
            self.lines.isHidden = true
        } else {
            var concatenated = ""
            let lineCount = lines!.count
            for i in 0..<lineCount {
                concatenated = concatenated + lines![i]
                if i < lineCount - 1 {
                    concatenated = concatenated + "\n"
                }
            }
            self.lines.text = concatenated
            self.lines.isHidden = false
        }
    }
    
    private func setTitle(_ title: String?) {
        if let title = title {
            self.title.text = title
            self.title.isHidden = false
        } else {
            self.title.text = ""
            self.title.isHidden = true
        }
    }
    
    private func setIconImage(_ icon: UIImage?) {
        if let icon = icon {
            self.icon.image = icon
        } else {
            self.icon.image = nil
        }
    }

}
