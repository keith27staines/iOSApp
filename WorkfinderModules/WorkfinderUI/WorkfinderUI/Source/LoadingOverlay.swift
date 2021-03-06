//
//  LoadingOverlay.swift
//  f4s-workexperience
//
//  Created by Andreea Rusu on 26/04/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import WorkfinderCommon
import UIKit

class LoadingOverlay: UIView {
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = WorkfinderColors.primaryColor
        return activityIndicator
    }()
    
    var caption: String = "" {
        didSet {
            captionLabel.text = caption
            captionLabel.isHidden = caption.isEmpty
        }
    }
    
    lazy var captionLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = 2
        label.layer.backgroundColor = UIColor.white.cgColor
        label.layer.cornerRadius = 10.0
        label.textAlignment = .center
        label.alpha = 0.9
        label.isHidden = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
        addSubview(captionLabel)
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        captionLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 20).isActive = true
        captionLabel.centerXAnchor.constraint(equalTo: activityIndicator.centerXAnchor, constant: 0).isActive = true
        captionLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        captionLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    func showOverlay() {
        self.backgroundColor = UIColor.clear
        self.alpha = 1
        self.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        activityIndicator.color = WFColorPalette.graphicsGreen
        guard let superview = superview else { return }
        guard !(superview is UITableView) else { return }
        fillSuperview()
    }

    func showLightOverlay() {
        showOverlay()
        self.backgroundColor = UIColor.clear
        activityIndicator.color = WFColorPalette.graphicsGreen
    }

    func hideOverlay() {
        guard superview != nil else { return }
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.alpha = 0
            self?.removeFromSuperview()
        })
    }
}
