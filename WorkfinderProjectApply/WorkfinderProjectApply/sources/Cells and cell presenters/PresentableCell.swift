
import UIKit

protocol PresentableCellProtocol: AnyObject {
    func refreshFromPresenter(_ presenter: CellPresenterProtocol, width: CGFloat)
    func setNeedsLayout()
}

class PresentableCell: UITableViewCell, PresentableCellProtocol {
    
    func refreshFromPresenter(_ presenter: CellPresenterProtocol, width: CGFloat) {
    
    }
    
    func configureViews() {
    
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

