
import UIKit
import WorkfinderUI

class PopularOnWorkfinderCell: HorizontallyScrollingCell, PresentableProtocol {

    static let identifier = "PopularOnWorkfinderCell"
    
    func presentWith(_ presenter: CellPresenterProtocol?) {
        guard let presenter = presenter as? PopularOnWorkfinderPresenter else { return }
        clear()
        presenter.capsulesData.forEach { (data) in
            addCapsule(data: data)
        }
    }
    
    func addCapsule(data: CapsuleData) {
        let view = CapsuleView(data: data)
        view.layer.cornerRadius = 45/2
        view.heightAnchor.constraint(equalToConstant: 45).isActive = true
        addCard(view)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        isPagingEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CapsuleView: UIView {
    var id: String {data.id}
    var text: String { data.title }
    let data: CapsuleData
    
    init(data: CapsuleData) {
        self.data = data
        super.init(frame: CGRect.zero)
        layer.masksToBounds = true
        layer.borderColor = UIColor(red: 151, green: 151, blue: 151).cgColor
        layer.borderWidth = 1
        tintColor = WorkfinderColors.primaryColor
        addSubview(stack)
        stack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(capsuleTapped)))
    }
    
    @objc func capsuleTapped() {
        NotificationCenter.default.post(name: .wfHomeScreenPopularOnWorkfinderTapped, object: data)
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


