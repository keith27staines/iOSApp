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
    weak var parent: ChooseNPSViewController?
    
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
        label.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        label.textColor = WorkfinderColors.gray2
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var textStack: UIStackView = {
        var textStack: UIStackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.addArrangedSubview(summary)
            stack.addArrangedSubview(title)
            stack.spacing = 30
            return stack
        }()
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.addArrangedSubview(Spacer(width: 20, height: 0))
        stack.addArrangedSubview(textStack)
        stack.addArrangedSubview(Spacer(width: 20, height: 0))
        stack.spacing = 0
        return stack
    }()
    
    lazy var table: UITableView = {
        let table = UITableView()
        table.backgroundColor = UIColor.white
        table.dataSource = self
        table.delegate = self
        table.tableFooterView = UIView()
        table.separatorStyle = .none
        table.tableHeaderView = makeDivider()
        return table
    }()
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.addArrangedSubview(textStack)
        stack.addArrangedSubview(table)
        stack.spacing = 8
        return stack
    }()
    
    private func configureViews() {
        addSubview(mainStack)
        mainStack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
    }
    
    init(parent: ChooseNPSViewController) {
        self.parent = parent
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
        let cell = QuestionCell(style: .default, reuseIdentifier: nil)
        guard let question = category?.questions[indexPath.row] else { return UITableViewCell() }
        cell.configureCellWithQuestion(question)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let question = category?.questions[indexPath.row] else { return }
        question.toggleAnswer()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        guard let cell = tableView.cellForRow(at: indexPath) as? QuestionCell else { return }
        let isChecked = question.answer.isChecked
        cell.answer.isHidden = !isChecked || !question.answerPermitsText
        cell.answer.isEnabled = isChecked
        if isChecked && question.answerPermitsText { cell.answer.becomeFirstResponder() }
    }
    
}

