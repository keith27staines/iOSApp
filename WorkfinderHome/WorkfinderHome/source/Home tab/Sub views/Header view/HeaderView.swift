

import UIKit
import WorkfinderUI

class HeaderView: UIView {
    
    let presenter: HeaderViewPresenter
    
    var height: CGFloat = 66 {
        didSet {
            heightConstraint.constant = height
        }
    }
    
    func refresh() {
        rightLabel.text = presenter.rightLabelText
    }
    
    private lazy var heightConstraint: NSLayoutConstraint = {
        self.heightAnchor.constraint(equalToConstant: height)
    }()
    
    private lazy var rightLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        label.textAlignment = .right
        label.text = ""
        return label
    }()
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            UIView(),
            rightLabel
        ])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private func configureViews() {
        addSubview(stack)
        stack.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 12, right: 20))
    }
    
    init(presenter: HeaderViewPresenter = HeaderViewPresenter()) {
        self.presenter = presenter
        super.init(frame: CGRect.zero)
        backgroundColor = WorkfinderColors.primaryColor
        heightConstraint.isActive = true
        configureViews()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
