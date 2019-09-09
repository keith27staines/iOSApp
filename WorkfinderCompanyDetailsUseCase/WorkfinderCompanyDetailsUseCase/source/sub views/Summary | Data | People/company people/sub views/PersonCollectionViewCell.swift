//
//  PersonCollectionViewCell.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 24/01/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import UIKit
import WorkfinderCommon

class PersonCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "PersonCollectionViewCell"
    
    var highlightedBorder: Bool = false {
        willSet {
            self.imageView.layer.borderColor = newValue ? UIColor.blue.cgColor : UIColor.darkGray.cgColor
        }
    }
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .semibold)
        label.textAlignment = .center
        label.allowsDefaultTighteningForTruncation = true
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    lazy var positionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .semibold)
        label.textAlignment = .center
        label.allowsDefaultTighteningForTruncation = true
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let image = UIImage(named: "person1")
        let imageView = UIImageView(image: image)
        imageView.layer.cornerRadius = 10
        imageView.layer.borderColor = UIColor.darkGray.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, imageView, positionLabel])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        stack.spacing = 4
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stack)
        stack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
    }
    
    func configure(person: PersonViewData) {
        if let imageName = person.imageName {
            imageView.image = UIImage(named: imageName)
        }
        nameLabel.text = person.fullName
        positionLabel.text = person.role
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
