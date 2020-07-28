import UIKit
import WorkfinderCommon
import WorkfinderUI

class ApplicationsViewController: UIViewController, WorkfinderViewControllerProtocol {

    lazy var messageHandler = UserMessageHandler(presenter: self)
    weak var coordinator: ApplicationsCoordinatorProtocol?
    let presenter: ApplicationsPresenter
    
    init(coordinator: ApplicationsCoordinatorProtocol, presenter: ApplicationsPresenter) {
        self.coordinator = coordinator
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        configureNavigationBar()
        configureViews()
        presenter.onViewDidLoad(view: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshFromPresenter()
        loadData()
    }
    
    func loadData() {
        messageHandler.showLoadingOverlay(view)
        presenter.loadData { [weak self] optionalError in
            guard let self = self else { return }
            self.messageHandler.hideLoadingOverlay()
            self.refreshFromPresenter()
            self.messageHandler.displayOptionalErrorIfNotNil(
                    optionalError,
                    retryHandler: self.loadData)
        }
    }
    
    lazy var noApplicationsYet:UILabel = {
        let label = UILabel()
        label.text = "You haven't made an application yet.\n\nWhy not search for companies and make an application now?"
        label.font = WorkfinderFonts.title2
        label.textColor = WorkfinderColors.textLight
        label.backgroundColor = WorkfinderColors.white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    func refreshFromPresenter() {
        tableView.reloadData()
        noApplicationsYet.removeFromSuperview()
        if presenter.numberOfRows(section: 0) == 0 {
            view.addSubview(noApplicationsYet)
            noApplicationsYet.translatesAutoresizingMaskIntoConstraints = false
            noApplicationsYet.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            noApplicationsYet.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            noApplicationsYet.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 30).isActive = true
            noApplicationsYet.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        }
    }
    
    func configureNavigationBar() {
        navigationItem.title = "Applications"
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        styleNavigationController()
    }
    
    func configureViews() {
        view.backgroundColor = UIColor.white
        view.addSubview(tableView)
        let guide = view.safeAreaLayoutGuide
        tableView.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20))
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ApplicationTile.self, forCellReuseIdentifier: ApplicationTile.reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
 
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
extension ApplicationsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRows(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ApplicationTile.reuseIdentifier) as? ApplicationTile else { return UITableViewCell() }
        let application = presenter.applicationTilePresenterForIndexPath(indexPath)
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
        presenter.onTapApplication(at: indexPath)
    }
}
