import UIKit
import WorkfinderCommon
import WorkfinderUI

class ApplicationsViewController: UIViewController, WorkfinderViewControllerProtocol {

    lazy var messageHandler = UserMessageHandler(presenter: self)
    weak var coordinator: ApplicationsCoordinatorProtocol?
    let presenter: ApplicationsPresenter

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    init(coordinator: ApplicationsCoordinatorProtocol, presenter: ApplicationsPresenter) {
        self.coordinator = coordinator
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        configureNavigationBar()
        configureViews()
        presenter.onViewDidLoad(view: self, table: tableView)
        NotificationCenter.default.addObserver(forName: .wfApplicationDataDidChange, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.loadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadData()
    }
    
    @objc func loadData() {
        showLoadingIndicators()
        presenter.loadData() { [weak self] optionalError in
            guard let self = self else { return }
            self.refreshFromPresenter()
            self.hideLoadingIndicators()
            DispatchQueue.main.async { [weak self] in
                self?.presenter.updateSnapshot()
            }
            self.messageHandler.displayOptionalErrorIfNotNil(
                    optionalError,
                    retryHandler: self.loadData)
        }
    }
    
    private lazy var navigationBarActivityItem: UIBarButtonItem = {
        let barButton = UIBarButtonItem(customView: navigationBarActivityIndicator)
        return barButton
    }()
    
    private lazy var navigationBarActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        indicator.color = WFColorPalette.readingGreen
        return indicator
    }()
    
    private lazy var navigationBarRefreshButton: UIBarButtonItem = {
        UIBarButtonItem.init(barButtonSystemItem: .refresh, target: self, action: #selector(loadData))
    }()
    
    private func showLoadingIndicators() {
        messageHandler.showLoadingOverlay(view)
        navigationItem.setRightBarButton(navigationBarActivityItem, animated: true)
        navigationBarActivityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicators() {
        messageHandler.hideLoadingOverlay()
        navigationBarActivityIndicator.stopAnimating()
        navigationItem.rightBarButtonItem = navigationBarRefreshButton
    }
    
    lazy var noApplicationsYetContainer: UIView = {
        let container = UIView()
        container.backgroundColor = UIColor.white
        container.addSubview(noApplicationsYet)
        noApplicationsYet.translatesAutoresizingMaskIntoConstraints = false
        noApplicationsYet.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        noApplicationsYet.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        noApplicationsYet.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 30).isActive = true
        return container
    }()
    
    lazy var noApplicationsYet:UILabel = {
        let label = UILabel()
        label.text = noApplicationsMessage
        label.font = WorkfinderFonts.title2
        label.textColor = WorkfinderColors.textLight
        label.backgroundColor = WorkfinderColors.white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    var noApplicationsMessage: String {
        switch presenter.isCandidateSignedIn() {
        case true:
            return presenter.isDataShown ? "" : "You don't appear to have made any applications yet.\n\nWhy not search for companies and make an application now?"
        case false:
            return "If you are signed-in and you have made applications, they will appear here"
        }
    }
    
    func refreshFromPresenter() {
        noApplicationsYetContainer.removeFromSuperview()
        if presenter.showNoApplicationsYetMessage {
            let guide = view.safeAreaLayoutGuide
            view.addSubview(noApplicationsYetContainer)
            noApplicationsYet.text = noApplicationsMessage
            noApplicationsYetContainer.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor)
            noApplicationsYetContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            noApplicationsYetContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            noApplicationsYetContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            noApplicationsYetContainer.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        }
    }
    
    func configureNavigationBar() {
        navigationItem.title = "Applications"
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        navigationItem.rightBarButtonItem = navigationBarRefreshButton
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
        tableView.register(TableSectionHeaderCell.self, forCellReuseIdentifier: "TableSectionHeaderCell")
        tableView.separatorStyle = .none
        tableView.delegate = self
        return tableView
    }()
 
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension ApplicationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let section = ApplicationsPresenter.Section(rawValue: section) else { return nil }
        let view = UIView()
        switch section {
        case .applicationsHeader:
            view.heightAnchor.constraint(equalToConstant: 1).isActive = true
            return view
        default: return view
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let section = ApplicationsPresenter.Section(rawValue: indexPath.section), section == .applications else {
            return
        }
        presenter.onTapApplication(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let section = ApplicationsPresenter.Section(rawValue: indexPath.section), section == .applications else {
            return nil
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let section = ApplicationsPresenter.Section(rawValue: indexPath.section), section == .applications else {
            return false
        }
        return section == .applications
    }

}
