import WorkfinderCommon
import WorkfinderCoordinators
import WorkfinderUI

public protocol ApplicationsCoordinatorProtocol {
    
}

public class ApplicationsCoordinator: CoreInjectionNavigationCoordinator, ApplicationsCoordinatorProtocol {
    
    lazy var applicationsViewController: UIViewController = {
        let vc = ApplicationsViewController()
        return vc
    }()
    
    public override func start() {
        navigationRouter.push(viewController: applicationsViewController, animated: true)
    }
}

enum ApplicationState {
    case viewed
    case declined
    
    var screenTitle: String {
        switch self {
        case .viewed: return "Application viewed"
        case .declined: return "Application declined"
        }
    }
    
    var description: String {
        switch self {
        case .viewed: return NSLocalizedString("The host has declined your applicatin", comment: "")
        case .declined: return "The host has declined your application"
        }
    }
}

class ApplicationsModel {
    class Application {
        let companyName: String
        let hostInformation: String
        let appliedDateString = "15-Mar-2020"
        let industry = "Aeronautical engineering"
        init(companyName: String, hostName: String) {
            self.companyName = companyName
            self.hostInformation = hostName
        }
    }
    
    private let applications = [
        Application(companyName: "Company 1", hostName: "Host 1 | role 1"),
        Application(companyName: "Company 2", hostName: "Host 2 | role 2"),
        Application(companyName: "Company 3", hostName: "Host 3 | role 3")
    ]
    
    let numberOfSections: Int = 1
    
    func numberOfRows(section: Int) -> Int {
        return applications.count
    }
    
    func applicationForIndexPath(_ indexPath: IndexPath) -> Application {
        return applications[indexPath.row]
    }
}

class ApplicationsViewController: UIViewController {
    let model = ApplicationsModel()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        configureViews()
        title = NSLocalizedString("Applications", comment: "")
    }
    
    func configureViews() {
        view.backgroundColor = UIColor.white
        view.addSubview(tableView)
        let guide = view.safeAreaLayoutGuide
        tableView.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ApplicationTile.self, forCellReuseIdentifier: ApplicationTile.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
 
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
extension ApplicationsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfRows(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ApplicationTile.reuseIdentifier) as? ApplicationTile else { return UITableViewCell() }
        let application = model.applicationForIndexPath(indexPath)
        cell.configureWithApplication(application)
        return cell
    }
}

extension ApplicationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class ApplicationTile: UITableViewCell {
    static let reuseIdentifier = "applicationCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: ApplicationTile.reuseIdentifier)
        configureViews()
    }
    
    lazy var logo: CompanyLogoView = {
        return CompanyLogoView()
    }()
    
    lazy var statusView: UILabel = {
       let label = UILabel()
        label.layer.cornerRadius = 15
        label.layer.masksToBounds = true
        label.backgroundColor = WorkfinderColors.primaryColor
        label.text = "viewed"
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.widthAnchor.constraint(equalToConstant: 64).isActive = true
        label.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return label
    }()
    
    lazy var logoStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [logo, statusView, UIView()])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    lazy var companyName: UILabel = {
        let label = UILabel()
        label.font = WorkfinderFonts.heading
        label.textColor = UIColor.black
        return label
    }()
    
    lazy var industry: UILabel = {
        let label = UILabel()
        label.font = WorkfinderFonts.subHeading
        label.textColor = WorkfinderColors.textMedium
        return label
    }()
    
    lazy var hostInformation: UILabel = {
        let label = UILabel()
        label.font = WorkfinderFonts.heading
        label.textColor = WorkfinderColors.textMedium
        return label
    }()
    
    lazy var dateString: UILabel = {
        let label = UILabel()
        label.font = WorkfinderFonts.subHeading
        label.textColor = WorkfinderColors.textMedium
        return label
    }()
    
    lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            companyName,
            industry,
            hostInformation,
            dateString,
            UIView()
        ])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [logoStack, textStack])
        stack.axis = .horizontal
        stack.spacing = 20
        return stack
    }()
    
    func configureViews() {
        self.contentView.addSubview(mainStack)
        mainStack.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: nil, padding: UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 0))
    }
    
    func configureWithApplication(_ application: ApplicationsModel.Application) {
        companyName.text = application.companyName
        industry.text = application.industry
        hostInformation.text = application.hostInformation
        dateString.text = application.appliedDateString
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class ApplicationDetailViewController: UIViewController {
    let state: ApplicationState
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = self.state.description
        return label
    }()
    
    init(state: ApplicationState) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        self.title = state.screenTitle
        configureViews()
    }
    
    func configureViews() {
        
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


