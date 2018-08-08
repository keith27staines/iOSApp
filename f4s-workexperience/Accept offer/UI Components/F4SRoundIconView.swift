//
//  RoundIconView.swift
//  ViewDesign
//
//  Created by Keith Staines on 21/07/2018.
//  Copyright © 2018 Keith Staines. All rights reserved.
//

import UIKit

@IBDesignable
class F4SRoundIconView: UIView {

    let imageView = UIImageView()
    
    @IBInspectable var strokeColor: UIColor = UIColor.white
    @IBInspectable var borderWidth: CGFloat = 4.0
    
    @IBInspectable var icon: UIImage? {
        didSet {
            configure()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    func setup() {
        
        // Setup image view
        imageView.layer.borderWidth = borderWidth
        imageView.layer.borderColor = strokeColor.cgColor
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        // Add constraints for imageView
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0).isActive = true
    }
    
    func configure() {
        imageView.image = icon
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = imageView.bounds.height / 2.0
    }
    
}
