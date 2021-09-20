//
//  DateCell.swift
//  WorkfinderInterviews
//
//  Created by Keith on 19/09/2021.
//

import UIKit
import WorkfinderUI

class DateCell: UITableViewCell {
    
    static let reuseIdentifier = "DateCell"
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    func configure(_ labelText: String, isSelected: Bool) {
        label.text = labelText
        var textStyle = WFTextStyle.labelTextBold
        let layer = contentView.layer
        switch isSelected {
        case true:
            layer.borderColor = WFColorPalette.readingGreen.cgColor
            layer.backgroundColor = WFColorPalette.readingGreen.cgColor
            textStyle.color = WFColorPalette.white
        case false:
            layer.borderColor = WFColorPalette.readingGreen.cgColor
            layer.backgroundColor = WFColorPalette.white.cgColor
            textStyle.color = WFColorPalette.readingGreen
        }
        label.applyStyle(textStyle)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = WFMetrics.borderWidth
        contentView.layer.masksToBounds = true
        contentView.addSubview(label)
        label.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

