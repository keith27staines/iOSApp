import UIKit
import WorkfinderUI

class ApplicationsViewController: UIViewController {

    weak var coordinator: ApplicationsCoordinatorProtocol?
    let presenter: ApplicationsPresenter
    
    init(coordinator: ApplicationsCoordinatorProtocol, presenter: ApplicationsPresenter) {
        self.coordinator = coordinator
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    let messageHandler =  UserMessageHandler()
    override func viewDidLoad() {
        configureViews()
        title = NSLocalizedString("Applications", comment: "")
        messageHandler.showLoadingOverlay(view)
        presenter.onViewDidLoad() { [weak self] error in
            guard let self = self else { return }
            self.messageHandler.hideLoadingOverlay()
            if let error = error {
                self.messageHandler.displayAlertFor(error.localizedDescription, parentCtrl: self)
            }
            self.tableView.reloadData()
        }
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
        let application = presenter.applicationTilePresenterForIndexPath(indexPath)
        presenter.onTapApplication(at: indexPath)
    }
}