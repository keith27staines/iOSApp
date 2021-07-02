//
//  EducationCell.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith on 02/07/2021.
//

import UIKit
import WorkfinderUI
import WorkfinderCommon

class EducationCell: UITableViewCell {
    static let reuseIdentifier = "EducationCell"
    
    lazy var school: UILabel = {
        let label = UILabel()
        return label
    }()

    lazy var degree: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var start: UILabel = {
        let label = UILabel()
        return label
    }()

    lazy var end: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(degree)
        stack.addArrangedSubview(school)
//        stack.addArrangedSubview(start)
//        stack.addArrangedSubview(end)
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()

    func configureWithEuduation(_ education : LIEducation) {
        school.text = education.schoolName?.string
        degree.text = education.degreeName?.string
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(stack)
        stack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 4, left: 20, bottom: 4, right: 4))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
