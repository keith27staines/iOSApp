import UIKit

class ApplicationDetailViewController: UIViewController {
    let presenter: ApplicationDetailPresenterProtocol
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = self.presenter.stateDescription
        return label
    }()
    
    init(coordinator: ApplicationsCoordinatorProtocol,
         presenter: ApplicationDetailPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        
        self.title = presenter.screenTitle
        configureViews()
    }
    
    func configureViews() {
        view.backgroundColor = UIColor.white
        view.addSubview(messageLabel)
        let guide = view.safeAreaLayoutGuide
        messageLabel.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
