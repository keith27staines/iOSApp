
import UIKit

protocol PresentableCellProtocol: AnyObject {
    var parentWidth: CGFloat { get set }
    func refreshFromPresenter(_ presenter: CellPresenterProtocol)
}

class PresentableCell: UICollectionViewCell, PresentableCellProtocol {
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
        widthConstraint = contentView.widthAnchor.constraint(equalToConstant: 1)
        widthConstraint.priority = UILayoutPriority(900)
        widthConstraint.isActive = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

