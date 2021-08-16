
import UIKit
import WorkfinderCommon
import WorkfinderUI

class TopRolesCell: HorizontallyScrollingCellWithPageControl, Presentable {
    static let identifier = "TopRolesView"
    let cardWidth = CGFloat(158)
    let cardHeight = CGFloat(262)
    
    func presentWith(_ presenter: CellPresenter?) {
        guard let presenter = presenter as? TopRolesPresenter else { return }
        presenter.load { [weak self] (optionalError) in
            guard let self = self else { return }
            self.clear()
            let roles = presenter.roles
            roles.forEach { (data) in
                self.addCardWith(data: data, tapAction: presenter.roleTapped)
            }
            if !roles.count.isMultiple(of: 2) {
                self.addShowPlaceholderCard()
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
    
    func addCardWith(data: RoleData, tapAction: @escaping (RoleData)->Void) {
        let card = PortraitRoleCard(data: data, tapAction: tapAction)
        card.widthAnchor.constraint(equalToConstant: cardWidth).isActive = true
        card.heightAnchor.constraint(equalToConstant: cardHeight).isActive = true
        addCard(card)
    }
}
