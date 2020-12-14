
import UIKit
import WorkfinderUI

class PortraitShowMoreCard: UIView {
    
    var tapAction: (() -> Void)?

    @objc func tapped() {
        tapAction?()
    }
    
    lazy var actionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "See more"
        label.textColor = WorkfinderColors.primaryColor
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        configureBorder()
        configureViews()
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
    }
    
    func configureViews() {
        addSubview(actionLabel)
        actionLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        actionLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        actionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
    }
    
    func configureBorder() {
        layer.cornerRadius = 14
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.init(white: 227/255, alpha: 1).cgColor
        layer.shadowRadius = 60
        layer.shadowColor = UIColor.init(white: 0, alpha: 0.04).cgColor
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}
