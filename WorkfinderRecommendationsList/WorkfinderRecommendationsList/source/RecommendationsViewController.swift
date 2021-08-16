
import UIKit
import WorkfinderUI

class RecommendationsViewController: UIViewController {
    
    lazy var messageHandler = UserMessageHandler(presenter: self)
    let presenter: RecommendationsPresenter
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textColor = UIColor.black
        label.heightAnchor.constraint(equalToConstant: 72).isActive = true
        label.textAlignment = .center
        label.text = "These roles might be a great match for you!"
        label.translatesAutoresizingMaskIntoConstraints = false
        let underline = UIView()
        underline.backgroundColor = UIColor.init(white: 200/255, alpha: 1)
        underline.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        label.addSubview(underline)
        underline.anchor(top: nil, leading: label.leadingAnchor, bottom: label.bottomAnchor, trailing: label.trailingAnchor)
        return label
    }()
    
    lazy var tableview: UITableView = {
        let view = UITableView()
        view.dataSource = self
        view.delegate = self
        view.separatorStyle = .none
        view.backgroundColor = UIColor.white
        view.register(RecommendationTileView.self, forCellReuseIdentifier: "recommendation")
        view.register(OpportunityTileView.self, forCellReuseIdentifier: "opportunity")
        return view
    }()
    
    init(presenter: RecommendationsPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    func reloadRow(_ indexPaths: [IndexPath]) {
        tableview.reloadRows(at: indexPaths, with: .automatic)
    }
    
    override func viewDidLoad() {
        presenter.onViewDidLoad(view: self)
        configureNavigationBar()
        configureViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard isMovingToParent else { return }
        loadData()
    }
    
    func configureNavigationBar() {
        navigationItem.title = "Recommendations"
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        styleNavigationController()
    }
    
    func configureViews() {
        view.backgroundColor = UIColor.white
        let guide = view.safeAreaLayoutGuide
        view.addSubview(titleLabel)
        view.addSubview(tableview)
        titleLabel.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: nil, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        tableview.anchor(top: titleLabel.bottomAnchor, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20))
    }
    
    func refresh() {
        tableview.reloadData()
    }
    
    func loadData() {
        refresh()
        messageHandler.showLoadingOverlay(self.view)
        presenter.loadFirstPage(table: tableview) { [weak self] (optionalError) in
            guard let self = self else { return }
            self.messageHandler.hideLoadingOverlay()
            self.messageHandler.displayOptionalErrorIfNotNil(optionalError) {
                self.loadData()
            }
            self.refresh()
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension RecommendationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }
}

extension RecommendationsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        presenter.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRowsForSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: return recommendationCellForRow(row: indexPath.row, in: tableview)
        case 1: return opportunitiesCellForRow(row: indexPath.row, in: tableview)
        default: return UITableViewCell()
        }
    }
    
    private func recommendationCellForRow(row: Int, in table: UITableView) -> UITableViewCell {
        guard let cell = table.dequeueReusableCell(withIdentifier: "recommendation") as? RecommendationTileView
            else { return UITableViewCell()
        }
        let tilePresenter = presenter.recommendationTilePresenterForIndexPath(row)
        cell.presenter = tilePresenter
        if row >= presenter.pager.triggerRow { presenter.loadNextPage(tableView: tableview) }
        return cell
    }
    
    private func opportunitiesCellForRow(row: Int, in table: UITableView) -> UITableViewCell {
        guard let cell = table.dequeueReusableCell(withIdentifier: "opportunity") as? OpportunityTileView
            else { return UITableViewCell()
        }
        let tilePresenter = presenter.opportunityTilePresenterForIndexPath(row)
        cell.presenter = tilePresenter
        if row >= presenter.pager.triggerRow { presenter.loadNextPage(tableView: tableview) }
        return cell
    }

}
