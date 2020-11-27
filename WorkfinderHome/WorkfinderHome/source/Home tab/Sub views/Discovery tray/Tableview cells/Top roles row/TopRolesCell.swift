
import UIKit
import WorkfinderUI

class TopRolesCell: HorizontallyScrollingCell, Presentable {
    static let identifier = "TopRolesView"
    let cardWidth = CGFloat(158)
    let cardHeight = CGFloat(262)
    
    func presentWith(_ presenter: CellPresenter?) {
        guard let presenter = presenter as? TopRolesPresenter else { return }
        presenter.load { [weak self] (result) in
            guard let self = self else { return }
            self.clear()
            switch result {
            case .success(let roles):
                roles.forEach { (data) in
                    self.addCardWith(data: data, tapAction: presenter.roleTapped)
                }
                if !roles.count.isMultiple(of: 2) {
                    self.addShowPlaceholderCard()
                }
            case .failure(_):
                break
            }
        }
    }
    
    func addShowPlaceholderCard() {
        let card = UIView()
        card.backgroundColor = UIColor.clear
        card.widthAnchor.constraint(equalToConstant: cardWidth).isActive = true
        card.heightAnchor.constraint(equalToConstant: cardHeight).isActive = true
        addCard(card)
    }
    
    func addCardWith(data: RoleData, tapAction: @escaping (String)->Void) {
        let card = PortraitRoleCard(data: data, tapAction: tapAction)
        card.widthAnchor.constraint(equalToConstant: 158).isActive = true
        card.heightAnchor.constraint(equalToConstant: 262).isActive = true
        addCard(card)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        isPagingEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
