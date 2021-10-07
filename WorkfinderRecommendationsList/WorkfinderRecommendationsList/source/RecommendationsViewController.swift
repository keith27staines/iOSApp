
import UIKit
import WorkfinderUI

class RecommendationsViewController: UIViewController, UserMessageHandlingProtocol {
    
    lazy var messageHandler: UserMessageHandler? = UserMessageHandler(presenter: self)
    let presenter: RecommendationsPresenter
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textColor = UIColor.black
        label.textAlignment = .left
        label.text = "We recommend you apply to these roles!"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var learnMoreLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap the cards to learn more"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(red: 0.37, green: 0.387, blue: 0.375, alpha: 1)
        return label
    }()
    
    lazy var headerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            learnMoreLabel
        ])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    lazy var tableview: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.separatorStyle = .none
        view.backgroundColor = UIColor.white
        view.register(OpportunityTileCellView.self, forCellReuseIdentifier: OpportunityTileCellView.reuseIdentifier)
        view.contentInset = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)
        view.scrollIndicatorInsets = view.contentInset
        return view
    }()
    
    init(presenter: RecommendationsPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        presenter.onViewDidLoad(view: self, table: tableview)
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
        navigationItem.rightBarButtonItem = navigationBarRefreshButton
        styleNavigationController()
    }
    
    func configureViews() {
        view.backgroundColor = UIColor.white
        let guide = view.safeAreaLayoutGuide
        view.addSubview(headerStack)
        view.addSubview(tableview)
        headerStack.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: nil, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 24, left: 20, bottom: 0, right: 20))
        tableview.anchor(top: headerStack.bottomAnchor, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 12, left: 20, bottom: 20, right: 20))
    }
    
    @objc func loadData() {
        showLoadingIndicators()
        presenter.loadData() { [weak self] (optionalError) in
            guard let self = self else { return }
            self.hideLoadingIndicators()
            self.messageHandler?.displayOptionalErrorIfNotNil(optionalError) {
                self.loadData()
            }
            self.presenter.applySnapshot()
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
        messageHandler?.showLoadingOverlay(view)
        navigationItem.setRightBarButton(navigationBarActivityItem, animated: true)
        navigationBarActivityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicators() {
        messageHandler?.hideLoadingOverlay()
        navigationBarActivityIndicator.stopAnimating()
        navigationItem.rightBarButtonItem = navigationBarRefreshButton
    }

    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension RecommendationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }
}
