
import UIKit
import WorkfinderUI

class Tab: UIView {
    let index: Int
    let selectedColor: UIColor
    let deselectedUnderlineColor = UIColor(white: 0.85, alpha: 1)
    let title: String
    var badgeText: String? = "" {
        didSet {
            titleBadge.text = badgeText
        }
    }
    let underlineHeight: CGFloat = 3
    var tapped: ((Tab) -> Void)?
    
    var isSelected: Bool = false {
        didSet {
            switch isSelected {
            case true:
                titleLabel.textColor = selectedColor
                selectedUnderline.backgroundColor = selectedColor
                deselectedUnderline.backgroundColor = UIColor.clear
                titleBadge.textColor = UIColor.white
                titleBadgeContainer.backgroundColor = selectedColor
            case false:
                titleLabel.textColor = UIColor.darkText
                selectedUnderline.backgroundColor = UIColor.clear
                deselectedUnderline.backgroundColor = deselectedUnderlineColor
                titleBadge.textColor = UIColor.black
                titleBadgeContainer.backgroundColor = deselectedUnderlineColor
            }
        }
    }
    
    lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            UIView(),
            titleLabel,
            titleBadgeContainer,
            UIView()
        ])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .equalCentering
        stack.alignment = .center
        return stack
    }()
    
    init(index: Int,
         title: String,
         selectedColor: UIColor = UIColor(red: 26/255, green: 168/255, blue: 76/255, alpha: 1),
         tapped: @escaping ((Tab) -> Void)) {
        self.index = index
        self.title = title
        self.selectedColor = selectedColor
        self.tapped = tapped
        super.init(frame: CGRect.zero)
        let stack = UIStackView(arrangedSubviews: [
            textStack,
            selectedUnderline,
            tableView
        ])
        addSubview(stack)
        stack.axis = .vertical
        stack.spacing = 8
        stack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        isUserInteractionEnabled = true
    }
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        return table
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = self.title
        label.textAlignment = .right
        label.textAlignment = .right
        label.textColor = UIColor.darkText
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        return label
    }()
    
    lazy var titleBadgeContainer: UIView = {
        let view = UIView()
        view.addSubview(titleBadge)
        titleBadge.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 1, left: 2, bottom: 1, right: 2))
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var titleBadge: UILabel = {
        let label = UILabel()
        label.text = badgeText
        label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize - 2)
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        label.widthAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true
        return label
    }()
    
    @objc func handleTap() {
        tapped?(self)
    }
    
    lazy var selectedUnderline: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: underlineHeight).isActive = true
        view.backgroundColor = UIColor.clear
        view.addSubview(deselectedUnderline)
        deselectedUnderline.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), size: CGSize(width: 0, height: 1))
        deselectedUnderline.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        return view
    }()
    
    lazy var deselectedUnderline: UIView = {
        let deselected = UIView()
        deselected.backgroundColor = deselectedUnderlineColor
        return deselected
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

