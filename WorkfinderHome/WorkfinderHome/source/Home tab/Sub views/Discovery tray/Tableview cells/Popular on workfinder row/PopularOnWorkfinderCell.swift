
import UIKit
import WorkfinderUI

class PopularOnWorkfinderCell: HorizontallyScrollingCell, Presentable {

    static let identifier = "PopularOnWorkfinderCell"
    
    func presentWith(_ presenter: CellPresenter?) {
        guard let presenter = presenter as? PopularOnWorkfinderPresenter else { return }
        presenter.capsulesData.forEach { (data) in
            addCapsule(data: data)
        }
        scrollView.layoutSubviews()
    }
    
    func addCapsule(data: CapsuleData) {
        let view = CapsuleView(text: data.text, id: data.id)
        view.layer.cornerRadius = 45/2
        view.heightAnchor.constraint(equalToConstant: 45).isActive = true
        contentStack.addArrangedSubview(view)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        updateHeightConstraint(verticalMargin: 20, scrollViewHeight: 45)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CapsuleView: UIView {
    let id: String
    let text: String
    
    init(text: String, id: String) {
        self.id = id
        self.text = text
        super.init(frame: CGRect.zero)
        layer.masksToBounds = true
        layer.borderColor = UIColor(red: 151, green: 151, blue: 151).cgColor
        layer.borderWidth = 1
        tintColor = UIColor(red: 33, green: 33, blue: 33)
        addSubview(stack)
        stack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
    }
    
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [label, icon])
        stack.spacing = 8
        stack.axis = .horizontal
        return stack
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = self.text
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = tintColor
        return label
    }()
    
    lazy var icon: UIImageView = {
        let icon = UIImageView(image: UIImage(named: "searchIcon"))
        icon.widthAnchor.constraint(equalToConstant: 16).isActive = true
        icon.tintColor = tintColor
        icon.contentMode = .scaleAspectFit
        return icon
    }()
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


