//
//  SectionHeaderView.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith on 26/05/2021.
//

import UIKit
import WorkfinderUI

class SectionHeaderView: UIView {

    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        return stack
    }()
    
    private lazy var title: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = UIColor.black
        return label
    }()

    private lazy var subtitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.darkGray
        return label
    }()
    
    init(section: YourDetailsPresenter.TableSection) {
        super.init(frame: CGRect.zero)
        if section.title.count > 0 {
            title.text = section.title
            stack.addArrangedSubview(title)
        }
        if section.subtitle.count > 0 {
            subtitle.text = section.subtitle
            stack.addArrangedSubview(subtitle)
        }
        addSubview(stack)
        stack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 8, left: 20, bottom: 4, right: 20))
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
