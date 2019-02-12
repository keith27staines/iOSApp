//
//  FilterButton.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 07/02/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import UIKit

class FilterButton: UIView {
    
    let innerRadius: CGFloat = 40 / 2
    var outerRadius: CGFloat { return sqrt(2) * innerRadius + 5}
    var side: CGFloat { return outerRadius * 2 }
    
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = outerRadius
        view.layer.masksToBounds = true
        view.layer.shadowColor = UIColor(white: 0.1, alpha: 1).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.5
        return view
    }()
    
    lazy var imageView: UIImageView = {
        let filterImage = #imageLiteral(resourceName: "filter")
        let view = UIImageView(image: filterImage)
        view.contentMode = .scaleAspectFit
        return  view
    }()
    
    var xConstraint: NSLayoutConstraint!
    var yConstraint: NSLayoutConstraint!
    
    func configure() {
        widthAnchor.constraint(equalToConstant: side).isActive = true
        heightAnchor.constraint(equalToConstant: side).isActive = true
        addSubview(backgroundView)
        backgroundView.addSubview(imageView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        backgroundView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        backgroundView.heightAnchor.constraint(equalToConstant: outerRadius * 2).isActive = true
        xConstraint = backgroundView.widthAnchor.constraint(equalToConstant: outerRadius * 2)
        xConstraint.isActive = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.white
        imageView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: innerRadius / 6 ).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: innerRadius * 2).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: innerRadius * 2).isActive = true
        layer.cornerRadius = outerRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.8
        layer.shadowOffset = CGSize(width: 0, height: 0)
        alpha = 0.95
        

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
}


