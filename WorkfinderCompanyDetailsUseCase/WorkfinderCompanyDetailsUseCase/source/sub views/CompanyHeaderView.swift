//
//  CompanyHeaderView.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 21/01/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI

protocol CompanyHeaderViewDelegate : class {
    func didTapApply()
}

class CompanyHeaderView: UIView {

    init(delegate: CompanyHeaderViewDelegate, companyViewModel: CompanyViewModel) {
        self.companyViewModel = companyViewModel
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.clear
        self.delegate = delegate
        configureViews()
        applyStyle()
        refresh()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    var companyViewModel: CompanyViewModel {
        didSet {
            refresh()
        }
    }
    
    var companyViewData: CompanyViewData { return companyViewModel.companyViewData }
    
    func refresh() {
        companyNameLabel.text = companyViewData.companyName
        companyIconImageView.load(urlString: companyViewData.logoUrlString, defaultImage: UIImage(named: "DefaultLogo"))
    }
    
    weak var delegate: CompanyHeaderViewDelegate?
    
    @objc func handleApplyTap() {
        delegate?.didTapApply()
    }
    
    lazy var applyButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleApplyTap), for: .touchUpInside)
        button.setTitle("Apply", for: UIControl.State.normal)
        return button
    }()
    
    lazy var companyIconImageView: F4SSelfLoadingImageView = {
        let imageView = F4SSelfLoadingImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 1
        imageView.layer.cornerRadius = 22
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var companyNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.minimumScaleFactor = 0.2
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    func configureViews() {
        addSubview(companyIconImageView)
        addSubview(companyNameLabel)
        addSubview(applyButton)
        applyButton.anchor(top: nil, leading: nil, bottom: nil, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12), size: CGSize(width: 80, height: 44))
        applyButton.centerYAnchor.constraint(equalTo: companyIconImageView.centerYAnchor).isActive = true
        companyIconImageView.anchor(top: topAnchor, leading: nil, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0), size: CGSize(width: 44, height: 44))
        companyIconImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        let bottom = companyIconImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        bottom.priority = .defaultLow
        bottom.isActive = true
        companyNameLabel.anchor(top: companyIconImageView.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: UIEdgeInsets(top: 8, left: 12, bottom: 0, right: 12), size: CGSize.zero)
        companyNameLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: 8).isActive = true
    }
    
    func applyStyle() {
        let skinner = Skinner()
        skinner.apply(buttonSkin: skin?.primaryButtonSkin, to: applyButton)
    }
}
