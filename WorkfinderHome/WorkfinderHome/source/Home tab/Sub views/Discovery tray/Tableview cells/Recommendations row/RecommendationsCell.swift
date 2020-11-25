
import UIKit
import WorkfinderUI

class RecommendationsCell: HorizontallyScrollingCell, Presentable {
    static let identifier = "RecommendationsView"
    
    func presentWith(_ presenter: CellPresenter?) {
        guard let presenter = presenter as? RecommendationsPresenter else { return }
        presenter.roles.forEach { (data) in
            addCard(data: data)
        }
    }
    
    func addCard(data: RoleData) {
        let card = PortraitRoleCard(data: data)
        card.widthAnchor.constraint(equalToConstant: 158).isActive = true
        card.heightAnchor.constraint(equalToConstant: 262).isActive = true
        contentStack.addArrangedSubview(card)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        updateHeightConstraint(verticalMargin: 20, scrollViewHeight: 262)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class PortraitRoleCard: UIView {
    
    lazy var logo: UIImageView = {
        let logo = UIImageView()
        logo.heightAnchor.constraint(equalToConstant: 30).isActive = true
        logo.contentMode = .scaleAspectFit
        return logo
    }()
    
    func makeSeparatorView() -> UIView {
        let line = UIView()
        line.widthAnchor.constraint(equalToConstant: 128).isActive = true
        line.backgroundColor = UIColor.init(white: 238/255, alpha: 1)
        let container = UIView()
        container.heightAnchor.constraint(equalToConstant: 1).isActive = true
        container.addSubview(line)
        line.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        line.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        return container
    }
    
    let projectTitle = UILabel()
    let paidHeader = UILabel()
    let paidAmount = UILabel()
    let locationHeader = UILabel()
    let location = UILabel()
    let actionButton = UIButton()
    
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
                logo,
                makeSeparatorView(),
                projectTitle,
                paidHeader,
                paidAmount,
                locationHeader,
                location,
                makeSeparatorView(),
                actionButton
            ]
        )
        stack.axis = .vertical
        stack.alignment = .fill
        stack.layoutSubviews()
        return stack
    }()
    
    let roleData: RoleData
    
    init(data: RoleData) {
        self.roleData = data
        super.init(frame: CGRect.zero)
        configureViews()
        refreshFromData(data)
    }
    
    func refreshFromData(_ data: RoleData) {
        logo.load(urlString: data.logoUrlString)
        projectTitle.text = data.projectTitle
        paidHeader.text = data.paidHeader
        paidAmount.text = data.paidAmount
        locationHeader.text = data.locationHeader
        location.text = data.location
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func configureViews() {
        addSubview(stack)
        stack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        layer.cornerRadius = 14
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.init(white: 227/255, alpha: 1).cgColor
        layer.shadowRadius = 60
        layer.shadowColor = UIColor.init(white: 0, alpha: 0.04).cgColor
    }
    
}
