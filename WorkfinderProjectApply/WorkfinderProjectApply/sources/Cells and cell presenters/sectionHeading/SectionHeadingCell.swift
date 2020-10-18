
import UIKit

class SectionHeadingCell: PresentableCell {
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        let height = label.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)
        height.priority = .defaultHigh
        height.isActive = true
        Style.sectionHeading.text.applyTo(label: label)
        return label
    }()
    
    override func refreshFromPresenter(_ presenter: CellPresenterProtocol, width: CGFloat) {
        guard let presenter = presenter as? SectionHeadingPresenterProtocol else { return }
        label.text = presenter.title
    }
    
    override func configureViews() {
        super.configureViews()
        label.font = UIFont.systemFont(ofSize: 20, weight: .thin)
        contentView.addSubview(label)
        label.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0))
    }
}
