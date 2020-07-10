
import UIKit
import WorkfinderUI

class RecommendationsViewController: UIViewController {
    
    lazy var messageHandler = UserMessageHandler(presenter: self)
    let presenter: RecommendationsPresenter
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textColor = UIColor.black
        label.heightAnchor.constraint(equalToConstant: 72).isActive = true
        label.textAlignment = .center
        label.text = "These roles are a perfect match for you!"
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
        return view
    }()
    
    lazy var noRecommendationsYet:UILabel = {
        let label = UILabel()
        label.text = "Please make your first application to start receiving recommendations"
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.backgroundColor = WorkfinderColors.white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
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
        updateDisplayOfNoRecommendationsYet()
    }
    
    func updateDisplayOfNoRecommendationsYet() {
        titleLabel.isHidden = presenter.noRecommendationsYet
        noRecommendationsYet.removeFromSuperview()
        guard presenter.noRecommendationsYet else { return }
        view.addSubview(noRecommendationsYet)
        noRecommendationsYet.translatesAutoresizingMaskIntoConstraints = false
        noRecommendationsYet.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        noRecommendationsYet.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noRecommendationsYet.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20).isActive = true
    }
    
    func loadData() {
        refresh()
        messageHandler.showLoadingOverlay(self.view)
        presenter.loadData() { [weak self] (optionalError) in
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "recommendation") as? RecommendationTileView
            else { return UITableViewCell()
        }
        let tilePresenter = presenter.recommendationTilePresenterForIndexPath(indexPath)
        cell.presenter = tilePresenter
        return cell
    }
}
