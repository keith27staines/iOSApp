
import UIKit

class SectionHeaderView: UITableViewHeaderFooterView {
    static let identifier = "SectionHeaderView"
    
    lazy var sectionTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        contentView.addSubview(label)
        label.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20))
        label.numberOfLines = 0
        label.textColor = UIColor.darkText
        return label
    }()
}

class SectionFooterView: UITableViewHeaderFooterView {
    static let identifier = "SectionFooterView"
    
    private lazy var separator: UIView = {
        let separator = UIView()
        separator.backgroundColor = UIColor.init(white: 216/255, alpha: 1)
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }()
    
    var isLineHidden: Bool {
        get {
            separator.isHidden
        }
        set {
            separator.isHidden = newValue
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(separator)
        separator.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20))
        isLineHidden = false
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
