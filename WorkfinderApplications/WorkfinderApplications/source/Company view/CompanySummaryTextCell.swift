
import UIKit

class CompanySummaryTextCell: UITableViewCell {
    static var reuseIdentifier = "CompanySummaryTextCell"
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        label.fillSuperview()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
