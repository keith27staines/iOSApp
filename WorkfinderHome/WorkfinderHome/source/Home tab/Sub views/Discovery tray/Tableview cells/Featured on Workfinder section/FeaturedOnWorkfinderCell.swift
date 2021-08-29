//
//  FeaturedOnWorkfinderCell.swift
//  WorkfinderHome
//
//  Created by Keith on 25/08/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI
import WorkfinderServices

class FeaturedOnWorkfinderCell: UITableViewCell, PresentableProtocol {
    static let identifier = "FeaturedOnWorkfinderCell"
    
    let standardSpace: CGFloat = 8
    let imageWidth: CGFloat = 87
    let margin: CGFloat = 16
    let gutterSpace: CGFloat = 20
    
    var presenter: CellPresenterProtocol?
    var row: Int = 0
    var roleData: RoleData = RoleData()
    var imageUrlString: String?
    let imageService = SmallImageService()
    
    func presentWith(_ presenter: CellPresenterProtocol?, width: CGFloat) {
        self.presenter = presenter
        self.roleData = presenter as? RoleData ?? RoleData()
        print(roleData)
        companyName.text = roleData.companyName
        projectTitle.text = roleData.projectTitle
        imageUrlString = roleData.companyLogoUrlString
        let defaultImage = UIImage.makeImageFromFirstCharacter(roleData.companyName ?? "?", size: CGSize(width: imageWidth, height: imageWidth))
        imageService.fetchImage(urlString: roleData.companyLogoUrlString, defaultImage: defaultImage) { [weak self] image in
            guard let self = self, self.imageUrlString == self.imageService.urlString else { return }
            self.companyLogo.image = image
        }
        
        var skills = roleData.skillsAcquired
        if skills.count > 3 {
            skills = [String](roleData.skillsAcquired.prefix(3))
            skills.append("... and more")
        }
        
        skillsStack.isHidden = skills.count == 0
        let widthForSkills = width - imageWidth - 2 * margin - gutterSpace
        skillsCapsules.reload(strings: skills, width: widthForSkills)
    }

    lazy var companyLogo: UIImageView = UIImageView.companyLogoImageView(width: imageWidth)
    
    lazy var companyLogoStack: UIStackView = {
        let spacer1 = UIView()
        let spacer2 = UIView()
        let stack = UIStackView(arrangedSubviews: [
            spacer1,
            companyLogo,
            spacer2
        ])
        stack.axis = .vertical
        stack.distribution = .fill
        spacer1.heightAnchor.constraint(equalTo: spacer2.heightAnchor).isActive = true
        return stack
    }()
    
    lazy var projectTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(red: 0.008, green: 0.188, blue: 0.161, alpha: 1)
        label.text = "Project Title"
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    lazy var companyName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = UIColor(red: 0.008, green: 0.188, blue: 0.161, alpha: 1)
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    lazy var titleStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            UIView.verticalSpaceView(height: standardSpace/2),
            projectTitle,
            companyName
        ])
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fill
        return stack
    }()
    
    lazy var skillsTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = UIColor(red: 0.37, green: 0.387, blue: 0.375, alpha: 1)
        label.text = "You will gain skills in"
        label.lineBreakMode = .byTruncatingTail
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var skillsCapsules: CapsuleCollectionView = {
        let view = CapsuleCollectionView(capsuleRadius: 12, minimumHorizontalSpacing: 8, minimumVerticalSpacing: 8)
        addSubview(view)
        return view
    }()
    
    lazy var skillsCapsulesStack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(skillsCapsules)
        stack.addArrangedSubview(UIView())
        stack.axis = .horizontal
        stack.distribution = .fill
        return stack
    }()
    
    lazy var skillsStack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(skillsTitle)
        stack.addArrangedSubview(skillsCapsulesStack)
        stack.spacing = standardSpace
        stack.axis = .vertical
        stack.distribution = .fill
        return stack
    }()
    
    lazy var rightStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            titleStack,
            skillsStack,
            UIView()
        ])
        stack.axis = .vertical
        stack.spacing = standardSpace
        return stack
    }()
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(companyLogoStack)
        stack.addArrangedSubview(rightStack)
        stack.spacing = gutterSpace
        stack.axis = .horizontal
        stack.alignment = .center
        return stack
    }()
    
    lazy var cardView: UIView = {
        let view = UIView()
        view.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        view.layer.cornerRadius = margin
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 0.762, green: 0.792, blue: 0.77, alpha: 1).cgColor
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellTapped)))
        view.addSubview(mainStack)
        mainStack.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin))
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
    }
    
    func configureViews() {
        contentView.addSubview(cardView)
        cardView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 8, left: margin, bottom: standardSpace, right: margin))
    }
    
    @objc func cellTapped() {
        NotificationCenter.default.post(name: .wfHomeScreenRoleTapped, object: roleData)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
