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
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
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
            stack.spacing = 20
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
    
    private lazy var table: UITableView = {
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
        if isChecked { cell.answer.becomeFirstResponder() }
    }
    
}

class QuestionCell: UITableViewCell {
    
    lazy var check: UIView = {
        let iv = UIImageView(image: UIImage(named: "tick"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        let view = UIView()
        view.addSubview(iv)
        iv.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        iv.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        view.widthAnchor.constraint(equalToConstant: 60).isActive = true
        return view
    }()
    
    lazy var question: UILabel = {
        let label = UILabel()
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.textColor = WorkfinderColors.gray2
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        return label
    }()

    lazy var answer: UITextField = {
        let text = UITextField()
        text.autocapitalizationType = .none
        text.borderStyle = .roundedRect
        text.setContentHuggingPriority(.defaultLow, for: .horizontal)
        text.textColor = WorkfinderColors.gray2
        text.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        text.backgroundColor = WorkfinderColors.gray6
        return text
    }()
    
    lazy var textStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.addArrangedSubview(question)
        stack.addArrangedSubview(answer)
        return stack
    }()
    
    lazy var horizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.addArrangedSubview(Spacer(width: 20, height: 0))
        stack.addArrangedSubview(textStack)
        stack.addArrangedSubview(check)
        let height = stack.heightAnchor.constraint(equalToConstant: 60)
        height.priority = .defaultHigh
        height.isActive = true
        return stack
    }()
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.addArrangedSubview(horizontalStack)
        stack.addArrangedSubview(makeDivider())
        stack.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return stack
    }()
    
    func configureCellWithQuestion(_ question: Question) {
        self.question.text = question.questionText
        check.isHidden = !question.answer.isChecked
        answer.isHidden = !question.answerPermitsText
        answer.text = question.answer.answerText
        answer.placeholder = "Add other reason"
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        textLabel?.textColor = WorkfinderColors.gray3
        tintColor = WorkfinderColors.primaryColor
        backgroundColor = UIColor.white
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(mainStack)
        mainStack.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 4, right: 0))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
