//
//  AnswersView.swift
//  WorkfinderNPS
//
//  Created by Keith Staines on 25/04/2021.
//

import UIKit
import WorkfinderUI

class QuestionsView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    var category: QuestionCategory?
    
    func configureWith(category: QuestionCategory?) {
        self.category = category
        summary.text = category?.summary
        title.text = category?.title
        table.reloadData()
    }
    
    private lazy var summary: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = WorkfinderColors.gray3
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var title: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = WorkfinderColors.gray2
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var textStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.addArrangedSubview(summary)
        stack.addArrangedSubview(title)
        stack.spacing = 12
        return stack
    }()
    
    private lazy var table: UITableView = {
        let table = UITableView()
        table.backgroundColor = WorkfinderColors.gray6
        table.dataSource = self
        table.tableFooterView = UIView()
        return table
    }()
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.addArrangedSubview(textStack)
        stack.addArrangedSubview(table)
        stack.spacing = 16
        return stack
    }()
    
    private func configureViews() {
        addSubview(mainStack)
        mainStack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        category?.questions.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        guard let question = category?.questions[indexPath.row] else { return UITableViewCell() }
        cell.textLabel?.text = question.text
        cell.textLabel?.textColor = WorkfinderColors.gray3
        switch question.answer {
        case .unchecked:
            cell.accessoryType = .none
        case .checked(_):
            cell.accessoryType = .checkmark
        }
        cell.contentView.backgroundColor = UIColor.white
        return cell
    }
}
