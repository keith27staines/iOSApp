import UIKit
import WorkfinderCommon
import WorkfinderUI

protocol WorkplaceListViewProtocol: class {
    var didSelectWorkplace: ((Workplace) -> Void)? { get set }
    var presenter: WorkplaceListPresenterProtocol! { get set }
    func refreshFromPresenter(_ presenter: WorkplaceListPresenterProtocol)
}

class WorkplaceListViewController: UIViewController {
    lazy var messageHandler = UserMessageHandler(presenter: self)
    let screenName = ScreenName.companyClusterList
    weak var log: F4SAnalyticsAndDebugging?
    var didSelectWorkplace: ((Workplace) -> Void)?
    var presenter: WorkplaceListPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        navigationItem.backBarButtonItem?.title = "Back"
        navigationItem.title = nil
        configureViews()
        presenter?.onViewDidLoad(self)
        loadData()
    }
    
    func loadData() {
        messageHandler.showLoadingOverlay(self.view)
        presenter?.loadData() { [weak self] optionalError in
            guard let self = self else { return }
            self.messageHandler.hideLoadingOverlay()
            self.refreshFromPresenter(self.presenter)
            self.messageHandler.displayOptionalErrorIfNotNil(
                optionalError,
                cancelHandler: {},
                retryHandler: self.loadData)
        }
    }
    
    func configureViews() {
        let guide = view.safeAreaLayoutGuide
        view.addSubview(pageStack)
        pageStack.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        configureTableView()
    }
    
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(WorkplaceTile.self, forCellReuseIdentifier: "WorkplaceTile")
    }
    lazy var headerView: UIView = {
        let spacer =  UIButton(type: UIButton.ButtonType.system)
        spacer.setTitle("Done", for: UIControl.State.normal)
        spacer.isHidden = true
        let headerLabel = UILabel()
        headerLabel.text = "Companies"
        headerLabel.textAlignment = .center
        let doneButton = UIButton(type: UIButton.ButtonType.system)
        doneButton.setTitle("Done", for: UIControl.State.normal)
        doneButton.addTarget(self, action: #selector(onTapDone), for: .touchUpInside)
        let view = UIView()
        let stack = UIStackView(arrangedSubviews: [spacer, headerLabel, doneButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        stack.fillSuperview(padding: UIEdgeInsets(top: 0, left: 8, bottom:0, right:12))
        stack.axis = .horizontal
        view.heightAnchor.constraint(equalToConstant: 64).isActive = true
        return view
    }()
    
    @objc func onTapDone() { dismiss(animated: true) }
    
    lazy var pageStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [headerView, tableView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        return stack
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView()
        return tableView
    }()
}

extension WorkplaceListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfTiles
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkplaceTile", for: indexPath) as! WorkplaceTile
        let viewData = presenter.companyTileViewData(index: indexPath.row)
        cell.configureWithViewData(viewData)
        return cell
    }
}

extension WorkplaceListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.onSelectRow(indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension WorkplaceListViewController: WorkplaceListViewProtocol {
    
    func refreshFromPresenter(_ presenter: WorkplaceListPresenterProtocol) {
        switchLoadingOverlay(on: presenter.showLoadingIndicator)
        tableView.reloadData()
    }
    
    func switchLoadingOverlay(on: Bool) {
        if on {
            messageHandler.showLoadingOverlay(view)
        } else {
            messageHandler.hideLoadingOverlay()
        }
    }
}




