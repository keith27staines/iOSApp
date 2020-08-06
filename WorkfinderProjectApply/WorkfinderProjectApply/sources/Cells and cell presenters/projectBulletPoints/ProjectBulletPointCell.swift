
import UIKit

class ProjectBulletPointWithTitleCell: PresentableCell {
    
    lazy var titleStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            title
        ])
        stack.axis = .horizontal
        return stack
    }()
    
    lazy var title: UILabel = {
        let label = UILabel()
        Style.bulletTitle.text.applyTo(label: label)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    lazy var text: UILabel = {
        let label = UILabel()
        Style.body.text.applyTo(label: label)
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    lazy var bullet: UILabel = {
        let label = UILabel()
        label.text = "\u{2022}"
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        return label
    }()
    
    lazy var bulletPointStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            bullet,
            text
        ])
        stack.axis = .horizontal
        stack.alignment = .firstBaseline
        stack.spacing = 20
        return stack
    }()
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            titleStack,
            bulletPointStack
        ])
        stack.axis = .vertical
        stack.spacing = 5
        return stack
    }()
    
    override func refreshFromPresenter(_ presenter: CellPresenterProtocol) {
        guard let presenter = presenter as? ProjectBulletPointsPresenterProtocol else { return }
        title.text = presenter.title
        text.text = presenter.text
    }
    
    override func configureViews() {
        super.configureViews()
        contentView.addSubview(mainStack)
        mainStack.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0))
    }
}
