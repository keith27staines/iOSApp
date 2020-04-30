import UIKit
import WorkfinderCommon
import WorkfinderUI

class SuccessPopupView: UIView {
    
    let leftButtonTapped: (() -> Void)?
    let rightButtonTapped: (() -> Void)?
    
    lazy var thumbsUpImageView: UIImageView = {
        let image = UIImage(named: "thumbsUp")
        let view = UIImageView(image: image)
        view.contentMode = .scaleAspectFit
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return view
    }()
    
    lazy var headingLabel: UILabel = {
        let label = UILabel()
        label.font = WorkfinderFonts.title2
        label.text = "Success we've received\nyour application!"
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.textColor = UIColor.darkText
        return label
    }()
    
    lazy var subheadingLabel: UILabel = {
        let label = UILabel()
        label.font = WorkfinderFonts.body
        label.text = "Tap Applications to monitor progress or\ntap Search to find more opportunities"
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.darkText
        return label
    }()
    
    lazy var leftButton: UIButton = {
        let button = WorkfinderPrimaryButton()
        button.setTitle(NSLocalizedString("Applications", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(onLeftButtonTapped), for: .touchUpInside)
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        button.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return button
    }()
    
    lazy var rightButton: UIButton = {
        let button = WorkfinderPrimaryButton()
        button.setTitle(NSLocalizedString("Search", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(onRightButtonTapped), for: .touchUpInside)
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        button.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return button
    }()
    
    lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.leftButton, self.rightButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 20
        stack.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return stack
    }()
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            self.thumbsUpImageView,
            self.headingLabel,
            self.subheadingLabel,
            self.buttonStack
        ])
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .fill
        stack.distribution = .fill
        stack.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return stack
    }()
    
    lazy var contentView: UIView = {
        let content = UIView()
        content.backgroundColor = UIColor.white
        content.addSubview(self.mainStack)
        self.mainStack.anchor(top: content.topAnchor, leading: content.leadingAnchor, bottom: content.bottomAnchor, trailing: content.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        content.translatesAutoresizingMaskIntoConstraints = false
        content.heightAnchor.constraint(equalTo: content.heightAnchor).isActive = true
        content.layer.cornerRadius = 12
        content.layer.masksToBounds = true
        return content
    }()
    
    @objc func onLeftButtonTapped() { self.leftButtonTapped?() }
    @objc func onRightButtonTapped() { self.rightButtonTapped?() }
    
    func configure() {
        backgroundColor = UIColor.init(white: 0.1, alpha: 0.3)
        addSubview(contentView)
        contentView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        contentView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        contentView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor).isActive = true
        contentView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor).isActive = true
        contentView.widthAnchor.constraint(equalToConstant: 320).isActive = true
    }
    
    init(leftButtonTapped: (() -> Void)?,
         rightButtonTapped: (() -> Void)?) {
        self.leftButtonTapped = leftButtonTapped
        self.rightButtonTapped = rightButtonTapped
        super.init(frame: CGRect.zero)
        configure()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
