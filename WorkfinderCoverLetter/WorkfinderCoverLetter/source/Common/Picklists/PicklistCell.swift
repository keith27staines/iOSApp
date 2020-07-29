
import UIKit
import WorkfinderCommon
import WorkfinderUI

class PicklistCell: UITableViewCell {
    
    func configureWithPicklist(_ picklist: PicklistProtocol, index: Int?) {
        configureQuestionIndex(index)
        configureQuestionTitle(picklist.type.questionTitle)
        configureQuestionExplanation(picklist.itemSelectedSummary, completed: picklist.isPopulated)
    }
    
    func configureQuestionIndex(_ index: Int?) {
        guard let index = index else {
            indexLabel.text = ""
            return
        }
        indexLabel.text = String(format: "%02d", index)
    }
    
    func configureQuestionTitle(_ title: String) {
        label1.text = title
    }
    
    func configureQuestionExplanation(_ explanation: String, completed: Bool) {
        label2.text = explanation
        switch completed {
        case true:
            label2.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            label2.textColor = WorkfinderColors.primaryColor
        case false:
            label2.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            label2.textColor = UIColor.gray
        }
    }
    
    
    lazy var indexStack: UIStackView = {
        let topSpacer = UIView()
        topSpacer.heightAnchor.constraint(equalToConstant: 3).isActive = true
        let stack = UIStackView(arrangedSubviews: [
            topSpacer,
            indexLabel,
            UIView()])
        stack.axis = .vertical
        return stack
    }()
    
    lazy var indexLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.gray
        label.numberOfLines = 1
        return label
    }()
    
    lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [label1, label2, UIView()])
        stack.spacing = 8
        stack.alignment = .leading
        stack.axis = .vertical
        return stack
    }()
    
    lazy var label1: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var label2: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    lazy var horizontalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [indexStack, textStack])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .firstBaseline
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(horizontalStack)
        horizontalStack.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
