
import UIKit
import WorkfinderUI

class SuccessViewController: UIViewController {
    
    var applicationsButtonTapped: (() -> Void)?
    var searchButtonTapped: (() -> Void)?
    
    lazy var successView: SuccessView = {
        SuccessView(applicationsButtonTap: self.applicationsButtonTapped, searchButtonTap: self.searchButtonTapped)
    }()

    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.init(white: 0.1, alpha: 0.2)
        configureViews()
    }
    
    func configureViews() {
        view.addSubview(successView)
        successView.translatesAutoresizingMaskIntoConstraints = false
        successView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    init(applicationsButtonTap: @escaping ()->Void, searchButtonTap: @escaping ()->Void) {
        super.init(nibName: nil, bundle: nil)
        self.applicationsButtonTapped = applicationsButtonTap
        self.searchButtonTapped = searchButtonTap
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SuccessView: UIView {
    
    let applicationsButtonTapped: (() -> Void)?
    let searchButtonTapped: (() -> Void)?
    
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
        label.text = "Tap Applications to monitor progress\nTap Search to find more opportunities"
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.darkText
        return label
    }()
    
    lazy var applicationsButton: UIButton = {
        let button = WorkfinderControls.makePrimaryButton()
        button.setTitle(NSLocalizedString("Applications", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(onLeftButtonTapped), for: .touchUpInside)
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        button.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return button
    }()
    
    lazy var searchButton: UIButton = {
        let button = WorkfinderControls.makePrimaryButton()
        button.setTitle(NSLocalizedString("Search", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(onRightButtonTapped), for: .touchUpInside)
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        button.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return button
    }()
    
    lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.applicationsButton, self.searchButton])
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
    
    @objc func onLeftButtonTapped() { self.applicationsButtonTapped?() }
    @objc func onRightButtonTapped() { self.searchButtonTapped?() }
    
    func configure() {
        addSubview(contentView)
        contentView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        contentView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        contentView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor).isActive = true
        contentView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor).isActive = true
        contentView.widthAnchor.constraint(equalToConstant: 320).isActive = true
    }
    
    init(applicationsButtonTap: (() -> Void)?,
         searchButtonTap: (() -> Void)?) {
        self.applicationsButtonTapped = applicationsButtonTap
        self.searchButtonTapped = searchButtonTap
        super.init(frame: CGRect.zero)
        configure()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
