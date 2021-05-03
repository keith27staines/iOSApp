//
//  QuestionCell.swift
//  WorkfinderNPS
//
//  Created by Keith Staines on 03/05/2021.
//

import UIKit
import WorkfinderUI

class QuestionCell: UITableViewCell {
    
    var question: Question?
    
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
    
    lazy var questionTextField: UILabel = {
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
        text.addTarget(self, action: #selector(onAnswerFieldValueChanged), for: .editingChanged)
        text.setContentHuggingPriority(.defaultHigh, for: .vertical)
        let width = text.widthAnchor.constraint(equalToConstant: 300)
        width.priority = .defaultLow
        width.isActive = true
        return text
    }()
    
    lazy var textStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.addArrangedSubview(questionTextField)
        stack.addArrangedSubview(answer)
        stack.spacing = 8
        return stack
    }()
    
    lazy var horizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.addArrangedSubview(Spacer(width: 20, height: 0))
        stack.addArrangedSubview(textStack)
        stack.addArrangedSubview(UIView())
        stack.addArrangedSubview(check)
        let height = stack.heightAnchor.constraint(equalToConstant: 60)
        height.priority = .defaultHigh
        height.isActive = true
        return stack
    }()
    
    lazy var verticalStack: UIStackView = {
        let space1 = UIView()
        let space2 = UIView()
        let stack = UIStackView()
        stack.axis = .vertical
        stack.addArrangedSubview(space1)
        stack.addArrangedSubview(horizontalStack)
        stack.addArrangedSubview(space2)
        space1.heightAnchor.constraint(equalTo: space2.heightAnchor, multiplier: 1).isActive = true
        return stack
    }()
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.addArrangedSubview(verticalStack)
        stack.addArrangedSubview(makeDivider())
        stack.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return stack
    }()
    
    func configureCellWithQuestion(_ question: Question) {
        self.question = question
        self.questionTextField.text = question.questionText
        check.isHidden = !question.answer.isChecked
        answer.isHidden = !question.answerPermitsText
        answer.text = question.answer.answerText
        answer.placeholder = "Add other reason"
    }
    
    @objc func onAnswerFieldValueChanged() {
        question?.answer = .init(isChecked: true, answerText: answer.text)
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
