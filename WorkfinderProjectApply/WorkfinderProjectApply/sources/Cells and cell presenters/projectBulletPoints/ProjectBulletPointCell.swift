
import UIKit

class ProjectBulletPointWithTitleCell: PresentableCell {
    
    lazy var title: UILabel = {
        let label = UILabel()
        Style.bulletTitle.text.applyTo(label: label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    lazy var bulletText: UILabel = {
        let label = UILabel()
        Style.body.text.applyTo(label: label)
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    lazy var bulletPoint: UILabel = {
        let label = UILabel()
        label.text = "\u{2022}"
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
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
        let height = stack.heightAnchor.constraint(equalToConstant: 20)
        height.priority = .defaultLow
        height.isActive = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func refreshFromPresenter(_ presenter: CellPresenterProtocol, width: CGFloat) {
        guard let presenter = presenter as? ProjectBulletPointsPresenterProtocol else { return }
        title.text = presenter.title
        bulletText.text = presenter.text
    }
    
    override func configureViews() {
        super.configureViews()
        contentView.addSubview(title)
        contentView.addSubview(bulletPointStack)
        title.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0))
        bulletPointStack.anchor(top: title.bottomAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0))
    }
}
