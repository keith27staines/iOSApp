
import UIKit

class KeyActivityCell: SimpleTextCell {
    
    lazy var bulletText: UILabel = {
        let label = UILabel()
        Style.body.text.applyTo(label: label)
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    lazy var bulletPoint: UILabel = {
        let label = UILabel()
        label.text = "\u{2022}"
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        return label
    }()
    
    lazy var bulletPointStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            bulletPoint,
            bulletText
        ])
        stack.axis = .horizontal
        stack.alignment = .firstBaseline
        stack.spacing = 20
        return stack
    }()
    
    override func refreshFromPresenter(_ presenter: CellPresenterProtocol) {
        guard let presenter = presenter as? KeyActivityPresenterProtocol else { return }
        bulletText.text = presenter.text
    }
    
    override func configureViews() {
        super.configureViews()
        contentView.addSubview(bulletPointStack)
        bulletPointStack.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
    }
}
