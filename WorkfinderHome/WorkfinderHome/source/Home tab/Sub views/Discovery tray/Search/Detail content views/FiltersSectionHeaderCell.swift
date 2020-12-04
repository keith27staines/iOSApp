
import UIKit
import WorkfinderUI

class FiltersSectionHeaderCell: UITableViewHeaderFooterView {
    
    var onTap: ((Int) -> Void)?
    var section: Int?
    
    lazy var sectionTitle: UILabel = {
        let label = UILabel()
        label.text = "Section header"
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureViews()
    }
    
    func configureViews() {
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(sectionTitle)
        sectionTitle.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0))
        sectionTitle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    @objc func handleTap() {
        guard let section = section else { return }
        onTap?(section)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
