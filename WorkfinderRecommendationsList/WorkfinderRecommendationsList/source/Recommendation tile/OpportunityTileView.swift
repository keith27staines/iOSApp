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
        skillsLabel.attributedText = presenter?.skillsAttributedString
        skillsLabel.sizeToFit()
        skillsStack.isHidden = presenter?.shouldHideSkills ?? true
    }
    
    lazy var companyLogo: UIImageView = {
        let view = UIImageView.companyLogoImageView(height: 46)
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
        label.text = "Location title"
        return label
    }()

    lazy var compensationTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(red: 0.37, green: 0.387, blue: 0.375, alpha: 1)
        label.text = "Compensation Title"
        return label
    }()
    
    lazy var locationName: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(red: 0.008, green: 0.188, blue: 0.161, alpha: 1)
        view.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        view.text = "Loction name"
        return view
    }()


    lazy var compensationName: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(red: 0.008, green: 0.188, blue: 0.161, alpha: 1)
        view.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        view.text = "Compensation name"
        return view
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
        print("Button tapped!!!")
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
        view.layer.borderColor = lineColor.cgColor
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
    
    private let lineColor: UIColor = UIColor(red: 0.762, green: 0.792, blue: 0.77, alpha: 1)
    
    private func makeSeparatorLine(insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)) -> UIView {
        let view = UIView()
        let line = UIView()
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        line.backgroundColor = lineColor
        view.addSubview(line)
        line.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: insets)
        view.heightAnchor.constraint(equalTo: line.heightAnchor, constant: insets.top + insets.bottom).isActive = true
        return view
    }
    
    private func makeSpacer(height: CGFloat) -> UIView {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        return  view
    }

    private func makeSpacer(width: CGFloat) -> UIView {
        let view = UIView()
        view.widthAnchor.constraint(equalToConstant: width).isActive = true
        return  view
    }

}



