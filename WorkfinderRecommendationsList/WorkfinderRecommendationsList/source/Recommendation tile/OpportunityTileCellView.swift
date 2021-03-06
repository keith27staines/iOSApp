//
//  OpportunityTileView.swift
//  WorkfinderRecommendationsList
//
//  Created by Keith on 13/08/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import UIKit
import WorkfinderUI

class OpportunityTileCellView: UITableViewCell, RefreshableProtocol {
    static let reuseIdentifier: String = "OpportunityTileViewCell"
    
    var data: OpportunityTileData? {
        didSet {
            refreshFromData(data)
        }
    }
    
    var companyLogoWidthConstraint: NSLayoutConstraint?
    
    func refreshFromData(_ data: OpportunityTileData?) {
        companyNameLabel.text = data?.companyName
        companyLogo.image = data?.companyImage?.aspectFitToSize(CGSize(width: CGFloat.infinity, height: 46))
        roleLabel.text = data?.projectTitle
        skillsLabel.attributedText = data?.skillsAttributedString
        skillsLabel.sizeToFit()
        skillsStack.isHidden = data?.shouldHideSkills ?? true
        locationValue.text = data?.locationValue
        compensationValue.text = data?.compensationValue
        companyLogo.load(urlString: data?.companyLogoUrlString, defaultImage: data?.defaultImage)
    }
    
    lazy var companyLogo: WFSelfLoadingImageViewWithFixedHeight = {
        let view = WFSelfLoadingImageViewWithFixedHeight(46)
        view.setContentHuggingPriority(.required, for: .horizontal)
        return view
    }()
    
    lazy var roleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(red: 0.008, green: 0.188, blue: 0.161, alpha: 1)
        label.textColor = UIColor.black
        label.text = "Role label"
        return label
    }()
    
    lazy var companyNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = UIColor(red: 0.008, green: 0.188, blue: 0.161, alpha: 1)
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.constrainToMaxlinesOrFewer(maxLines: 2)
        return label
    }()
    
    lazy var topStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            roleLabel,
            companyNameLabel,
            makeSeparatorLine(insets: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0))
        ])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    lazy var skillsTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(red: 0.37, green: 0.387, blue: 0.375, alpha: 1)
        label.text = "You will gain skills in:"
        label.numberOfLines = 1
        return label
    }()
    
    lazy var skillsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(red: 0.008, green: 0.188, blue: 0.161, alpha: 1)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.numberOfLines = 0
        return label
    }()

    lazy var skillsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            makeSpacer(height: 16),
            skillsTitle,
            makeSpacer(height: 12),
            skillsLabel,
            makeSpacer(height: 16),
            makeSeparatorLine()
        ])
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()
    
    lazy var locationTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(red: 0.37, green: 0.387, blue: 0.375, alpha: 1)
        label.text = "Location"
        return label
    }()

    lazy var compensationTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(red: 0.37, green: 0.387, blue: 0.375, alpha: 1)
        label.text = "Compensation"
        return label
    }()
    
    lazy var locationValue: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(red: 0.008, green: 0.188, blue: 0.161, alpha: 1)
        view.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        view.text = "Location"
        return view
    }()


    lazy var compensationValue: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(red: 0.008, green: 0.188, blue: 0.161, alpha: 1)
        view.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        view.text = "Compensation"
        return view
    }()

    lazy var locationStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            locationTitle,
            locationValue
        ])
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()

    lazy var compensationStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            compensationTitle,
            compensationValue
        ])
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()
    
    lazy var primaryButton: WorkfinderPrimaryGradientButton = {
        let button = WorkfinderPrimaryGradientButton()
        button.setTitle("Easy Apply", for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func buttonTapped() {
        data?.onApplyTapped()
    }
    
    lazy var bottomStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            locationStack,
            compensationStack
        ])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
                
    lazy var fullStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            topStack,
            skillsStack,
            makeSpacer(height: 16),
            bottomStack,
            makeSpacer(height: 16),
            primaryButton
        ])
        stack.spacing = 0
        stack.alignment = .fill
        stack.axis = .vertical
        return stack
    }()
    
    lazy var tileView: UIView = {
        let view = UIView()
        view.addSubview(companyLogo)
        view.addSubview(fullStack)
        companyLogo.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 0))
        fullStack.anchor(top: companyLogo.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 16
        view.layer.borderColor = ruleLineColor.cgColor
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        isUserInteractionEnabled = true
        configureViews()
    }
    
    func configureViews() {
        contentView.addSubview(tileView)
        contentView.backgroundColor = UIColor.white
        tileView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 12, left: 4, bottom: 12, right: 4))
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    @objc func handleTap() { data?.onTileTapped() }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

}

extension UIView {
    
    var ruleLineColor: UIColor {
        UIColor(red: 0.762, green: 0.792, blue: 0.77, alpha: 1)
    }
    
    func makeSeparatorLine(insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)) -> UIView {
        let view = UIView()
        let line = UIView()
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        line.backgroundColor = ruleLineColor
        view.addSubview(line)
        line.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: insets)
        view.heightAnchor.constraint(equalTo: line.heightAnchor, constant: insets.top + insets.bottom).isActive = true
        return view
    }
    
    func makeSpacer(height: CGFloat) -> UIView {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        return  view
    }

    func makeSpacer(width: CGFloat) -> UIView {
        let view = UIView()
        view.widthAnchor.constraint(equalToConstant: width).isActive = true
        return  view
    }
}



