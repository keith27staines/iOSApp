
import UIKit

protocol PresentableCellProtocol: AnyObject {
    var parentWidth: CGFloat { get set }
    func refreshFromPresenter(_ presenter: CellPresenterProtocol)
    func setNeedsLayout()
}

class PresentableCell: UITableViewCell, PresentableCellProtocol {
    var widthConstraint: NSLayoutConstraint!
    
    func refreshFromPresenter(_ presenter: CellPresenterProtocol) {
        // Should override
    }
    
    var parentWidth: CGFloat = 0 {
        didSet {
            if parentWidth == 0 {
                widthConstraint.isActive = false
            } else {
                widthConstraint.constant = parentWidth
                widthConstraint.isActive = true
            }
        }
    }
    
    func configureViews() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.anchor(top: self.topAnchor, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: self.trailingAnchor)
        widthConstraint = contentView.widthAnchor.constraint(equalToConstant: 1)
        widthConstraint.priority = UILayoutPriority(900)
        widthConstraint.isActive = false
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

