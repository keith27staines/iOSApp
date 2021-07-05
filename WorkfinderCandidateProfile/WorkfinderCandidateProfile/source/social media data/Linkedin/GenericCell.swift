//
//  GenericCell.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith on 02/07/2021.
//

import UIKit
import WorkfinderUI
import WorkfinderCommon

class GenericCell: UITableViewCell {
    static let reuseIdentifier = "GenericCell"

    lazy var field1: UILabel = {
        let label = UILabel()
        label.textColor = WorkfinderColors.black
        return label
    }()
    
    lazy var field2: UILabel = {
        let label = UILabel()
        label.textColor = WorkfinderColors.gray3
        return label
    }()
    
    lazy var start: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()

    lazy var end: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(field1)
        stack.addArrangedSubview(field2)
        stack.addArrangedSubview(start)
        stack.addArrangedSubview(end)
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }()

    func configureWithEducation(_ education: LIEducation) {
        field1.isHidden = false
        field2.isHidden = false
        field1.text = education.degreeName?.string
        field2.text = education.schoolName?.string
        configureStartAndEndDates(startMonthYear: education.startMonthYear, endMonthYear: education.endMonthYear)
    }
    
    func configureWithPosition(_ position: LIPosition) {
        field1.isHidden = false
        field2.isHidden = false
        field1.text = position.companyName?.string
        field2.text = position.title?.string
        configureStartAndEndDates(startMonthYear: position.startMonthYear, endMonthYear: position.endMonthYear)
    }
    
    func configureWithSkill(_ skill: LISkill) {
        field1.isHidden = false
        field1.text = skill.name?.string
        field2.isHidden = true
        configureStartAndEndDates(startMonthYear: nil, endMonthYear: nil)
    }
    
    func configureStartAndEndDates(startMonthYear: LIMonthYear?, endMonthYear: LIMonthYear?) {
        let startYear = startMonthYear?.year
        let startMonth = startMonthYear?.month
        let endYear = endMonthYear?.year
        let endMonth = endMonthYear?.month
        let startDateString = dateStringFrom(year: startYear, month: startMonth)
        let endDateString = dateStringFrom(year: endYear, month: endMonth)
        start.isHidden = startDateString == nil
        end.isHidden = endDateString == nil
        start.text = "Start: \(startDateString ?? "")"
        end.text = "End: \(endDateString ?? "")"
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(stack)
        stack.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 4))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func dateStringFrom(year: Int?, month: Int?) -> String? {
        guard let year = year else { return nil }
        let components = DateComponents(calendar: .current, year: year, month: month)
        guard let date = components.date else { return nil }
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df.string(from: date)
    }
    
}
