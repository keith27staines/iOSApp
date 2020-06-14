
import UIKit
import WorkfinderCommon
import WorkfinderUI

class LoadingViewController: UIViewController {
    
    lazy var userMessageHandler = UserMessageHandler(presenter: self)
    let presenter: LoadingViewPresenter
    
    init(presenter: LoadingViewPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    lazy var container: UIView = {
        let container = UIView()
        container.layer.cornerRadius = 8
        container.backgroundColor = UIColor.white
        container.addSubview(stack)
        stack.anchor(top: container.topAnchor, leading: container.leadingAnchor, bottom: container.bottomAnchor, trailing: container.trailingAnchor, padding: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))
        return container
    }()
    
    lazy var titleStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            activity
        ])
        stack.spacing = 8
        stack.axis = .horizontal
        return stack
    }()
    
    lazy var activity: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .whiteLarge)
        activity.color = WorkfinderColors.primaryColor
        activity.hidesWhenStopped = true
        return activity
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Loading recommendation"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = WorkfinderFonts.body2
        label.numberOfLines = 0
        label.text = "Please wait a moment while the recommendation is loading"
        return label
    }()
    
    lazy var closeButton: UIView = {
        let button = WorkfinderSecondaryButton()
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(onCancel), for: .touchUpInside)
        return button
    }()
    
    @objc func onCancel() { presenter.onCancel() }
    
    lazy var stack:UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            self.titleStack,
            self.descriptionLabel,
            self.closeButton,
        ])
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.init(white: 0.9, alpha: 0.3)
        view.isOpaque = false
        presenter.onViewDidLoad(self)
        configureViews()
        loadData()
    }
    
    func configureViews() {
        view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        container.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
    }
    
    func loadData() {
        activity.startAnimating()
        presenter.loadData() { [weak self] optionalError in
            guard let self = self else { return }
            self.activity.stopAnimating()
            self.userMessageHandler.displayOptionalErrorIfNotNil(optionalError, cancelHandler: {
                self.presenter.onCancel()
            }) {
                self.loadData()
            }
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
