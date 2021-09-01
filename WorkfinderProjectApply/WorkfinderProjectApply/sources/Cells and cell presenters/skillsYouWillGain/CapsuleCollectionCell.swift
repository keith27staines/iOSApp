
import UIKit
import WorkfinderUI

class CapsuleCollectionCell: PresentableCell {
    
    lazy var capsuleCollectionView: CapsuleCollectionView = {
        let view = CapsuleCollectionView()
        return view
    }()
    
    override func refreshFromPresenter(_ presenter: CellPresenterProtocol, width: CGFloat) {
        guard let presenter = presenter as? CapsuleCollectionPresenterProtocol else { return }
        capsuleCollectionView.reload(strings: presenter.strings, width: width)
    }
    
    override func configureViews() {
        super.configureViews()
        contentView.addSubview(capsuleCollectionView)
        capsuleCollectionView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        let height = contentView.heightAnchor.constraint(equalToConstant: 0)
        height.priority = .defaultLow
        height.isActive = true
    }
}
