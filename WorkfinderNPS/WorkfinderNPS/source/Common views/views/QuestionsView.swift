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
        table.backgroundColor = UIColor.white
        table.dataSource = self
        table.delegate = self
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
    
    init() {
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
    
    lazy var textStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.addArrangedSubview(question)
        return stack
    }()
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.addArrangedSubview(textStack)
        stack.addArrangedSubview(check)
        stack.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return stack
    }()
    
    func configureCellWithQuestion(_ question: Question) {
        self.question.text = question.text
        switch question.answer {
        case .unchecked: check.isHidden = true
        case .checked: check.isHidden = false
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        textLabel?.textColor = WorkfinderColors.gray3
        tintColor = WorkfinderColors.primaryColor
        backgroundColor = UIColor.white
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(mainStack)
        mainStack.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
