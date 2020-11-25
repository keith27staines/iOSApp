
import UIKit
import WorkfinderUI

class TopRolesCell: HorizontallyScrollingCell, Presentable {
    static let identifier = "TopRolesView"
    
    func presentWith(_ presenter: CellPresenter?) {
        guard let presenter = presenter as? TopRolesPresenter else { return }
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
        scrollView.backgroundColor = UIColor.init(white: 247/255, alpha: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
