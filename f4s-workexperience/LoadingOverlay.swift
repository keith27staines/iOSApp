//
//  LoadingOverlay.swift
//  f4s-workexperience
//
//  Created by Andreea Rusu on 26/04/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import UIKit

class LoadingOverlay: UIView {
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let centerX = self.frame.width / 2
        let centerY = self.frame.height / 2
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activityIndicator.frame = CGRect(x: centerX - (activityIndicator.frame.width) / 2, y: centerY - (activityIndicator.frame.height) / 2, width: (activityIndicator.frame.width), height: (activityIndicator.frame.height))
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    var caption: String = "" {
        didSet {
            captionLabel.text = caption
        }
    }
    
    lazy var captionLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = 2
        label.layer.backgroundColor = UIColor.white.cgColor
        label.layer.cornerRadius = 10.0
        label.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 20).isActive = true
        label.centerXAnchor.constraint(equalTo: activityIndicator.centerXAnchor, constant: 0).isActive = true
        label.heightAnchor.constraint(equalToConstant: 60).isActive = true
        label.widthAnchor.constraint(equalToConstant: 200).isActive = true
        label.textAlignment = .center

        label.alpha = 0.9
        return label
    }()

    func showOverlay() {
        self.backgroundColor = UIColor(netHex: Colors.black)
        self.alpha = 0.75

        self.translatesAutoresizingMaskIntoConstraints = false

        let superview = self.superview
        if let _ = superview as? UITableView {
            return
        } else {
            addSubview(activityIndicator)
            setConstraints()
            activityIndicator.startAnimating()
        }
    }

    func showLightOverlay() {
        showOverlay()
        self.backgroundColor = UIColor(netHex: Colors.white)
        activityIndicator.color = UIColor.gray
    }

    func hideOverlay() {
        guard superview != nil else {
            // Not shown, therefore there is nothing to do
            return
        }
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0
            self.removeFromSuperview()
        })
    }

    func setConstraints() {
        // Loading View

        let leadingConstraintCharView = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1, constant: 0)
        let topConstraintCharView = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: superview, attribute: .top, multiplier: 1, constant: 0)
        let trailingConstraintCharView = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1, constant: 0)
        let bottomConstraintCharView = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: superview, attribute: .bottom, multiplier: 1, constant: 0)

        self.superview?.addConstraints([leadingConstraintCharView, topConstraintCharView, trailingConstraintCharView, bottomConstraintCharView])

        // activityIndicator view constraints

        let centerYConstraintCharView = NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        let centerXConstraintCharView = NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)

        self.superview?.addConstraints([centerYConstraintCharView, centerXConstraintCharView])
    }
}
