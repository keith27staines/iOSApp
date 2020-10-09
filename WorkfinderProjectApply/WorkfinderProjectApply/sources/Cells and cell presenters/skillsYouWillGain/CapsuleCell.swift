
import UIKit

class CapsuleCell: PresentableCell {
    
    override var parentWidth: CGFloat { didSet {} }
    
    override func refreshFromPresenter(_ presenter: CellPresenterProtocol) {
        guard let presenter = presenter as? CapsulePresenterProtocol else { return }
        label.text = presenter.text
    }
    
    lazy var capsule: UIView = {
        let view = UIView()
        let radius: CGFloat = 23
        view.layer.cornerRadius = radius
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.darkGray.cgColor
        view.addSubview(label)
        view.layer.masksToBounds = true
        // view.heightAnchor.constraint(equalToConstant: radius * 2).isActive = true
        label.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: radius, bottom: 0, right: radius))
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        return view
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    override func configureViews() {
        super.configureViews()
        contentView.addSubview(capsule)
        capsule.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }
    
}
