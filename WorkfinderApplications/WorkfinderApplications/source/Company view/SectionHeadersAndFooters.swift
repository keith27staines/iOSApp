
import UIKit

class SectionHeaderView: UITableViewHeaderFooterView {
    
    let label = UILabel()
    
    func setSectionTitle(_ string: String?) { label.text = string }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        tintColor = UIColor.white
        addSubview(label)
        label.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = UIColor.gray
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class SectionFooterView: UITableViewHeaderFooterView {
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        heightAnchor.constraint(greaterThanOrEqualToConstant: 12).isActive = true
        self.frame.size.height = 12
        tintColor = UIColor.white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
