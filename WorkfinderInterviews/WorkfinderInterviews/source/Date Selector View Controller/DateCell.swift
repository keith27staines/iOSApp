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
    
    lazy var tile: UIView = {
        let tile = UIView()
        tile.addSubview(label)
        label.anchor(top: tile.topAnchor, leading: tile.leadingAnchor, bottom: tile.bottomAnchor, trailing: tile.trailingAnchor)
        tile.layer.cornerRadius = 8
        tile.layer.borderWidth = WFMetrics.borderWidth
        tile.layer.masksToBounds = true
        return tile
    }()
    
    func configure(_ labelText: String, isSelected: Bool) {
        label.text = labelText
        var textStyle = WFTextStyle.labelTextBold
        let layer = tile.layer
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
    
    private func configureViews() {
        contentView.addSubview(tile)
        tile.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0))
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

