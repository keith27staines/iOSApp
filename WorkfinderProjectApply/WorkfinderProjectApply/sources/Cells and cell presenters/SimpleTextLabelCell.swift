
import UIKit

class SimpleTextCell: PresentableCell {
    
    lazy var label: UILabel = {
        let label = UILabel()
        return label
    }()
    
    override func configureViews() {
        super.configureViews()
        label.font = UIFont.systemFont(ofSize: 17)
        contentView.addSubview(label)
        label.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }
}
