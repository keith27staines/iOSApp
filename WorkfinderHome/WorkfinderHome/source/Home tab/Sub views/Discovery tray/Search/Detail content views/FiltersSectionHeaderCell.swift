
import UIKit
import WorkfinderUI

class FiltersSectionHeaderCell: UITableViewHeaderFooterView {
    
    var onTap: ((Int) -> Void)?
    var section: Int?
    var isExpanded: Bool = false {
        didSet {
            chevron.image = isExpanded ? Self.chevronUp : Self.chevronDown
        }
    }
    
    lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(sectionTitle)
        stack.addArrangedSubview(chevron)
        stack.axis = .horizontal
        return stack
    }()
    
    lazy var sectionTitle: UILabel = {
        let label = UILabel()
        label.text = "Section header"
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    lazy var chevron: UIImageView = {
        let view = UIImageView()
        view.widthAnchor.constraint(equalToConstant: 12).isActive = true
        view.contentMode = .scaleAspectFit
        view.image = Self.chevronDown
        view.tintColor = WorkfinderColors.primaryColor
        return view
    }()
    
    static var chevronUp: UIImage? = {
        let image = UIImage(named: "chevron_up")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        return image
    }()
    
    static var chevronDown: UIImage? = {
        let image = UIImage(named: "chevron_down")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        return image
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureViews()
    }
    
    func configureViews() {
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(stack)
        stack.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0))
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    @objc func handleTap() {
        guard let section = section else { return }
        onTap?(section)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
