//
//  OfferCellTile.swift
//  WorkfinderApplications
//
//  Created by Keith on 22/09/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import UIKit
import WorkfinderUI

class OfferTileCell: UIView {
    typealias CellData = OfferData
    static var identifier = "OfferCell"
    private var _size = CGSize(width: 0, height: 0)
        
    func configure(with data: OfferData, size: CGSize) {
        _size = size
        let defaultImage = UIImage.makeImageFromFirstCharacter(data.defaultImageText ?? "?", size: CGSize(width: imageHeight, height: imageHeight))
        imageView.load(urlString: data.imageUrlString, defaultImage: defaultImage)
        button.text = data.buttonText
        button.state = data.buttonState
        button.buttonTapped = {
            data.tapAction?(data)
        }
        textLabel.text = data.text
    }

    var imageHeight: CGFloat = 46
    var buttonHeight: NSLayoutConstraint?
    var frameHeight: CGFloat = 100
    let space = WFMetrics.standardSpace
    let halfspace = WFMetrics.halfSpace
    
    func configure(with data: OfferData) {
        let defaultImage = UIImage.makeImageFromFirstCharacter(data.defaultImageText ?? "?", size: CGSize(width: imageHeight, height: imageHeight))
        imageView.load(urlString: data.imageUrlString, defaultImage: defaultImage)
        button.text = data.buttonText
        button.state = data.buttonState
        button.buttonTapped = {
            data.tapAction?(data)
        }
        textLabel.text = data.text
    }
    
    private lazy var imageView: WFSelfLoadingImageView = {
        let view = WFSelfLoadingImageViewWithHeight(height: 46)
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        var style = WFTextStyle.labelTextRegular
        style.color = UIColor(red: 0.008, green: 0.188, blue: 0.161, alpha: 1)
        label.applyStyle(style)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var button: WFButton = {
        let button = WFButton(heightClass: .larger)
        return button
    }()
    
    private lazy var mainStack: UIStackView = {
        let variableSpace = UIView()
        let stack = UIStackView(arrangedSubviews: [
                textLabel,
                variableSpace,
                button
            ]
        )
        stack.axis = .vertical
        stack.spacing = halfspace
        return stack
    }()
    
    func configureViews() {
        addSubview(imageView)
        imageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: space, left: space, bottom: 0, right: 0))
        addSubview(mainStack)
        mainStack.anchor(top: imageView.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: space, left: space, bottom: space, right: space))
        layer.borderWidth = 1
        layer.borderColor = WFColorPalette.grayBorder.cgColor
        layer.cornerRadius = space
        layer.masksToBounds = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
