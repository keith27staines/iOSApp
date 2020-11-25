
import UIKit
import WorkfinderUI

class RecommendationsCell: HorizontallyScrollingCell, Presentable {
    static let identifier = "RecommendationsView"
    
    func presentWith(_ presenter: CellPresenter?) {
        
    }
    
    override func configureViews() {
        super.configureViews()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        updateHeightConstraint(verticalMargin: 20, scrollViewHeight: 368)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
