
import UIKit
import WorkfinderUI

class RecommendationsCell: HorizontallyScrollingCell, Presentable {
    static let identifier = "RecommendationsView"
    let cardWidth = CGFloat(158)
    let cardHeight = CGFloat(262)
    
    func presentWith(_ presenter: CellPresenter?) {
        guard let presenter = presenter as? RecommendationsPresenter else { return }
        presenter.load { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let roles):
                self.clear()
                let maxRoles = min(9, roles.count)
                roles[0..<maxRoles].forEach { (data) in
                    let role = data.settingAppSource(.homeTabRecommendationsList)
                    self.addCardWith(data: role, tapAction: presenter.roleTapped)
                }
                let lastCardType = presenter.lastCardType
                guard lastCardType != .none else { break }
                self.addShowMoreCard(text: lastCardType.title, tapAction: presenter.moreTapped)
                if roles.count.isMultiple(of: 2) { self.addShowPlaceholderCard() }
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
    
    func addShowMoreCard(text: String, tapAction: @escaping ()->Void) {
        let card = PortraitLastCard(text: text)
        card.tapAction = tapAction
        card.widthAnchor.constraint(equalToConstant: cardWidth).isActive = true
        card.heightAnchor.constraint(equalToConstant: cardHeight).isActive = true
        addCard(card)
    }
    
    func addCardWith(data: RoleData, tapAction: @escaping (RoleData) -> Void) {
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



