//
//  OpportunityTileView.swift
//  WorkfinderRecommendationsList
//
//  Created by Keith on 13/08/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import UIKit
import WorkfinderUI

class OpportunityTileView: UITableViewCell {
    
    var presenter: OpportunityTilePresenterProtocol? {
        didSet {
            refreshFromPresenter(presenter: presenter)
        }
    }
    
    var companyLogoWidthConstraint: NSLayoutConstraint?
    
    func refreshFromPresenter(presenter: OpportunityTilePresenterProtocol?) {
        companyNameLabel.text = presenter?.companyName
        companyLogo.image = presenter?.companyImage?.aspectFitToSize(CGSize(width: CGFloat.infinity, height: 46))
        roleLabel.text = presenter?.projectTitle
        skillsLabel.text = presenter?.skills
    }
    
    lazy var companyLogo: UIImageView = {
        let view = UIImageView.companyLogoImageView(height: 46)
        view.setContentHuggingPriority(.required, for: .horizontal)
        return view
    }()
    
    lazy var roleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = UIColor.black
        label.text = "Role label"
        return label
    }()
    
    lazy var companyNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.constrainToMaxlinesOrFewer(maxLines: 2)
        return label
    }()
    
    lazy var topStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            roleLabel,
            companyNameLabel
        ])
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()
    
    lazy var skillsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = UIColor.black
        label.numberOfLines = 0
        return label
    }()

    lazy var middleStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            skillsLabel
        ])
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()
    
    lazy var locationTitle: UILabel = {
        let label = UILabel()
        label.text = "Location"
        return label
    }()

    lazy var locationName: UILabel = {
        let label = UILabel()
        label.text = "Manchester"
        return label
    }()

    lazy var compensationTitle: UILabel = {
        let label = UILabel()
        label.text = "Compensation"
        return label
    }()

    lazy var compensationName: UILabel = {
        let label = UILabel()
        label.text = "Paid"
        return label
    }()

    lazy var locationStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            locationTitle,
            locationName
        ])
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()

    lazy var compensationStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            compensationTitle,
            compensationName
        ])
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()
    
    lazy var primaryButton: WorkfinderPrimaryGradientButton = {
        let button = WorkfinderPrimaryGradientButton()
        button.setTitle("Apply", for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func buttonTapped() {
        
    }
    
    lazy var bottomStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            locationStack,
            compensationStack
        ])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        return stack
    }()
                
    lazy var fullStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            topStack,
            middleStack,
            bottomStack,
            primaryButton
        ])
        stack.spacing = 20
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
        view.layer.borderColor = WorkfinderColors.lightGrey.cgColor
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
        tileView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    @objc func handleTap() { presenter?.onTileTapped() }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
