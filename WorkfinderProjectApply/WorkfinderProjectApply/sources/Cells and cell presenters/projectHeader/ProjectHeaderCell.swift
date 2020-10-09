
import UIKit

class ProjectHeaderCell: PresentableCell {
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        let height = label.heightAnchor.constraint(equalToConstant: 50)
        height.priority = .defaultLow
        height.isActive = true
        return label
    }()
    
    override func refreshFromPresenter(_ presenter: CellPresenterProtocol) {
        guard let presenter = presenter as? ProjectHeaderPresenterProtocol else { return }
        label.attributedText = presenter.attributedTitle
    }
    
    override func configureViews() {
        super.configureViews()
        contentView.addSubview(label)
        label.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }
}
