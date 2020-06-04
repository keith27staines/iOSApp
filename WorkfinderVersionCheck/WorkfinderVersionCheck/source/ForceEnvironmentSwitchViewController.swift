
import UIKit
import WorkfinderCommon
import WorkfinderUI

class ForceEnvironmentSwitchViewController: UIViewController {
    
    let serverEnvironment: EnvironmentType
    let localStoreEnvironment: EnvironmentType?
    
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
            self.logo,
            self.hardStop,
            self.reason,
            self.serverStack,
            self.localStack,
            self.advice
        ])
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 8
        return stack
    }()
    
    lazy var hardStop: UILabel = {
        let label = UILabel()
        label.text = "Hard stop"
        label.font = WorkfinderFonts.largeTitle
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var reason: UILabel = {
        let label = UILabel()
        label.text = "Inconsistent server and local storage detected"
        label.font = WorkfinderFonts.heading
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var serverStack: UIStackView = {
        let name = UILabel()
        name.textAlignment = .right
        name.text = "Server:"
        name.textColor = UIColor.gray
        let value = UILabel()
        value.textAlignment = .left
        value.text = self.serverEnvironment.rawValue
        value.font = UIFont.boldSystemFont(ofSize: 20)
        let stack = UIStackView(arrangedSubviews: [name, value])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    lazy var localStack: UIStackView = {
        let name = UILabel()
        name.text = "local storage:"
        name.textAlignment = .right
        name.textColor = UIColor.gray
        let value = UILabel()
        value.textAlignment = .left
        value.text = self.localStoreEnvironment?.rawValue ?? "unknown"
        value.font = UIFont.boldSystemFont(ofSize: 20)
        let stack = UIStackView(arrangedSubviews: [name, value])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    lazy var advice: UILabel = {
        let label = UILabel()
        label.text = "Please delete this app from your device and install a build that corresponds to the environment you intend to use"
        label.textColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.8)
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
    
    init(serverEnvironment: EnvironmentType,
         localStoreEnvironment: EnvironmentType?) {
        self.serverEnvironment = serverEnvironment
        self.localStoreEnvironment = localStoreEnvironment
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

