
import UIKit

class SectionHeaderView: UITableViewHeaderFooterView {
    static let identifier = "SectionHeaderView"
    
    lazy var sectionTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        contentView.addSubview(label)
        label.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor)
        label.numberOfLines = 0
        label.textColor = UIColor.darkText
        contentView.backgroundColor = UIColor.white
        return label
    }()
}

class SectionFooterView: UITableViewHeaderFooterView {
    static let identifier = "SectionFooterView"
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
