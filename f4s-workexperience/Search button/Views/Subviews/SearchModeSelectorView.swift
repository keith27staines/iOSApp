//
//  SearchModeSelectorView.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 13/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import UIKit

class SearchModeSelectorView: UIStackView {
    
    private let imageView: UIView
    private let label: UILabel
    private var tapped: (SearchModeSelectorView) -> Void
    
    override var tintColor: UIColor! {
        didSet {
            imageView.tintColor = tintColor
            label.textColor = tintColor
        }
    }
    
    init(imageName: String, text: String, tapped: @escaping (SearchModeSelectorView) -> Void) {
        let image = UIImage(named: imageName)!.withRenderingMode(.alwaysTemplate)
        self.tapped = tapped
        imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.heightAnchor.constraint(equalToConstant: 36).isActive = true
        label = UILabel()
        label.isUserInteractionEnabled = true
        label.text = text
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        label.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.horizontal)
        super.init(frame: CGRect.zero)
        addArrangedSubview(imageView)
        addArrangedSubview(label)
        distribution = .fillProportionally
        axis = .vertical
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    @objc func handleTap() {
        tapped(self)
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
