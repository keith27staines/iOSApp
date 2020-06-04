
import UIKit
import WorkfinderCommon
import WorkfinderUI
//
class ForceAppUpdateViewController: UIViewController {
    
    let presenter: ForceUpdatePresenter
    
    lazy var logo: UIImageView = {
        let workfinderLogo = UIImage(named: "logo")?.withRenderingMode(.alwaysTemplate)
        let logo = UIImageView(image: workfinderLogo)
        logo.tintColor = WorkfinderColors.primaryColor
        logo.heightAnchor.constraint(equalToConstant: 128).isActive = true
        logo.widthAnchor.constraint(equalToConstant: 128).isActive = true
        logo.contentMode = .scaleAspectFit
        return logo
    }()
    
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            logo,
            copy,
            updateButton
        ])
        stack.axis = .vertical
        return stack
    }()
    
    lazy var updateButton: UIButton = {
        let button = WorkfinderPrimaryButton()
        button.setTitle(NSLocalizedString("Update from the Appstore", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(appStore), for: .touchUpInside)
        return button
    }()
    
    lazy var copy: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("This version of Workfinder is out of date and can no longer be used\n\n\nA newer version is available\n\nPlease update", comment: "Note that every '\n' indicates a new line")
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = WorkfinderColors.white
        configureViews()
    }
    
    func configureViews() {
        let guide = view.safeAreaLayoutGuide
        view.backgroundColor = WorkfinderColors.white
        view.addSubview(stack)
        stack.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 40, left: 20, bottom: 20, right: 20))
    }

    @objc func appStore(_ sender: Any?) { presenter.gotoAppStore() }
    
    init(presenter: ForceUpdatePresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
