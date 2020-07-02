
import UIKit
import WorkfinderUI

class RecommendationsViewController: UIViewController {
    
    lazy var messageHandler = UserMessageHandler(presenter: self)
    let presenter: RecommendationsPresenter
    
    lazy var tableview: UITableView = {
        let view = UITableView()
        view.dataSource = self
        view.delegate = self
        view.register(UITableViewCell.self, forCellReuseIdentifier: "recommendation")
        return view
    }()
    
    lazy var noRecommendationsYet:UILabel = {
        let label = UILabel()
        label.text = "No recommendations yet.\n\nRecommendations will begin appearing here soon after you have made your first application"
        label.font = WorkfinderFonts.title2
        label.textColor = WorkfinderColors.textLight
        label.backgroundColor = WorkfinderColors.white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    init(presenter: RecommendationsPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
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
        view.addSubview(tableview)
        tableview.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
    }
    
    func refresh() {
        tableview.reloadData()
        updateDisplayOfNoRecommendationsYet()
    }
    
    func updateDisplayOfNoRecommendationsYet() {
        noRecommendationsYet.removeFromSuperview()
        guard presenter.noRecommendationsYet else { return }
        view.addSubview(noRecommendationsYet)
        noRecommendationsYet.translatesAutoresizingMaskIntoConstraints = false
        noRecommendationsYet.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        noRecommendationsYet.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noRecommendationsYet.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 30).isActive = true
        noRecommendationsYet.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "recommendation") else {
            return UITableViewCell()
        }
        let recommendation = presenter.recommendationForIndexPath(indexPath)
        cell.textLabel?.text = recommendation.association
        return cell
    }
}

class RecommendationTilePresenter {
    var view: RecommendationTileView?
    var companyName: String?
    
}



class RecommendationTileView: UITableViewCell {
    
    var presenter: RecommendationTilePresenter? {
        didSet {
            presenter?.view = self
            refreshFromPresenter()
        }
    }
    
    override func prepareForReuse() {
        presenter?.view = nil
        presenter = nil
    }
    
    func refreshFromPresenter() {
        
    }
    
    lazy var companyNameLabel = UILabel()
    lazy var industryLabel = UILabel()
    lazy var hostNameLabel = UILabel()
    lazy var hostRoleLabel = UILabel()
    lazy var companyLogo = CompanyLogoView()
    lazy var hostPhoto = F4SSelfLoadingImageView()
    
    lazy var companyStack: UIStackView = {
        let textStack = UIStackView(arrangedSubviews: [
            self.companyNameLabel,
            self.industryLabel
        ])
        textStack.axis = .vertical
        textStack.spacing = 8
        let stack = UIStackView(arrangedSubviews: [
            self.companyLogo,
            textStack
        ])
        stack.axis = .horizontal
        stack.spacing = 12
        return stack
    }()
    
    lazy var hostStack: UIStackView = {
        let textStack = UIStackView(arrangedSubviews: [
            self.hostNameLabel,
            self.hostRoleLabel
        ])
        textStack.axis = .vertical
        textStack.spacing = 8
        let stack = UIStackView(arrangedSubviews: [
            self.hostPhoto,
            textStack
        ])
        stack.axis = .horizontal
        stack.spacing = 12
        return stack
    }()
    
    lazy var fullStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            self.companyStack,
            self.hostStack
        ])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(fullStack)
        fullStack.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 4))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
