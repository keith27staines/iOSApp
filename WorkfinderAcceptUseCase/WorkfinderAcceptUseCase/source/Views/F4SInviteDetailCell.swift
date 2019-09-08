//
//  F4SInviteDetailCell.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 25/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

public class F4SInviteDetailCell: UITableViewCell {
    
    lazy var title: UILabel = {
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        title.textColor = UIColor.darkText
        title.numberOfLines = 0
        return title
    }()
    
    lazy var lines: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo", size: 15) // Menlo is a fixed width font, needed to keep alignment for numbers
        label.textColor = UIColor.darkText
        label.numberOfLines = 0
        return label
    }()
    
    lazy var icon: UIImageView = {
        let iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconView)
        iconView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        iconView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        iconView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8).isActive = true
        iconView.contentMode = .scaleAspectFit
        return iconView
    }()
    
    lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fillProportionally
        stack.spacing = 8
        contentView.addSubview(stack)
        stack.topAnchor.constraint(equalTo: icon.topAnchor, constant: 0).isActive = true
        stack.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 12).isActive = true
        stack.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8).isActive = true
        stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30).isActive = true
        return stack
    }()
    
    public var detail: F4SPlacementInviteSectionDetails? {
        didSet {
            stack.removeArrangedSubview(title)
            stack.removeArrangedSubview(lines)
            title.removeFromSuperview()
            lines.removeFromSuperview()
            guard let detail = detail else { return }
            setIconImage(detail.icon)
            setTitle(detail.title)
            setlines(lines: detail.lines)
        }
    }
    
    private func setlines(lines: [String]?) {
        if lines == nil || lines?.isEmpty == true {
            return
        }
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
        stack.addArrangedSubview(self.lines)
    }
    
    private func setTitle(_ title: String?) {
        if let title = title {
            self.title.text = title
            stack.addArrangedSubview(self.title)
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
