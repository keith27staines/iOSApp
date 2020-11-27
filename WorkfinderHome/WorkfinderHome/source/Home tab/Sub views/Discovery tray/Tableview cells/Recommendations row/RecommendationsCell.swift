
import UIKit
import WorkfinderUI

class RecommendationsCell: HorizontallyScrollingCell, Presentable {
    static let identifier = "RecommendationsView"
    let cardWidth = CGFloat(158)
    let cardHeight = CGFloat(262)
    
    func presentWith(_ presenter: CellPresenter?) {
        guard let presenter = presenter as? RecommendationsPresenter else { return }
        presenter.roles.forEach { (data) in
            addCardWith(data: data, tapAction: presenter.roleTapped)
        }
        if presenter.isMoreCardRequired {
            addShowMoreCardIfRequired(tapAction: presenter.moreTapped)
        }
    }
    
    func addShowMoreCardIfRequired(tapAction: @escaping ()->Void) {
        let card = PortraitShowMoreCard()
        card.tapAction = tapAction
        card.widthAnchor.constraint(equalToConstant: cardWidth).isActive = true
        card.heightAnchor.constraint(equalToConstant: cardHeight).isActive = true
        addCard(card)
    }
    
    func addCardWith(data: RoleData, tapAction: @escaping (String) -> Void) {
        let card = PortraitRoleCard(data: data, tapAction: tapAction)
        card.widthAnchor.constraint(equalToConstant: cardWidth).isActive = true
        card.heightAnchor.constraint(equalToConstant: cardHeight).isActive = true
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



