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
    var activityIndicator: UIActivityIndicatorView?

    func showOverlay() {
        self.backgroundColor = UIColor(netHex: Colors.black)
        self.alpha = 0.75

        self.translatesAutoresizingMaskIntoConstraints = false
        let centerX = self.frame.width / 2
        let centerY = self.frame.height / 2

        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        self.activityIndicator?.frame = CGRect(x: centerX - (self.activityIndicator?.frame.width)! / 2, y: centerY - (self.activityIndicator?.frame.height)! / 2, width: (self.activityIndicator?.frame.width)!, height: (self.activityIndicator?.frame.height)!)

        self.activityIndicator?.translatesAutoresizingMaskIntoConstraints = false
        let superview = self.superview
        if let _ = superview as? UITableView {
            return
        } else {
            self.addSubview(self.activityIndicator!)
            setConstraints()
            self.activityIndicator?.startAnimating()
        }
    }

    func showLightOverlay() {
        self.backgroundColor = UIColor(netHex: Colors.white)
        self.alpha = 0.75

        self.translatesAutoresizingMaskIntoConstraints = false

        let centerX = self.frame.width / 2
        let centerY = self.frame.height / 2

        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        self.activityIndicator?.color = UIColor.gray
        self.activityIndicator?.frame = CGRect(x: centerX - (self.activityIndicator?.frame.width)! / 2, y: centerY - (self.activityIndicator?.frame.height)! / 2, width: (self.activityIndicator?.frame.width)!, height: (self.activityIndicator?.frame.height)!)

        self.activityIndicator?.translatesAutoresizingMaskIntoConstraints = false
        let superview = self.superview
        if let _ = superview as? UITableView {
            return
        } else {
            self.addSubview(self.activityIndicator!)
            setConstraints()
            self.activityIndicator?.startAnimating()
        }
    }

    func hideOverlay() {
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

        // activityIndicator view constrains

        let centerYConstraintCharView = NSLayoutConstraint(item: (self.activityIndicator)!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        let centerXConstraintCharView = NSLayoutConstraint(item: (self.activityIndicator)!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)

        self.superview?.addConstraints([centerYConstraintCharView, centerXConstraintCharView])
    }
}
