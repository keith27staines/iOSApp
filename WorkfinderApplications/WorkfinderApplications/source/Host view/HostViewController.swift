
import WorkfinderCommon
import WorkfinderUI

class HostViewController: UIViewController, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        let content = cell.contentView
        content.addSubview(hostView)
        hostView.anchor(top: content.topAnchor, leading: content.leadingAnchor, bottom: content.bottomAnchor, trailing: content.trailingAnchor)
        return cell
    }
    
    lazy var userMessageHandler = UserMessageHandler(presenter: self)
    let presenter: HostViewPresenter
    
    lazy var hostView: HostLocationAssociationView = {
        let view = HostLocationAssociationView(showSelectionButton: false)
        view.backgroundColor = WorkfinderColors.white
        return view
    }()
    
    override func viewDidLoad() {
        configureNavigationBar()
        configureViews()
        presenter.onViewDidLoad(view: self)
        loadData()
    }
    
    func loadData() {
        userMessageHandler.showLoadingOverlay(self.view)
        presenter.loadData { [weak self] (optionalError) in
            guard let self = self else { return }
            self.userMessageHandler.hideLoadingOverlay()
            self.userMessageHandler.displayOptionalErrorIfNotNil(optionalError) {
                self.loadData()
            }
            self.hostView.configureWith(host: self.presenter.host, association: self.presenter.association)
            self.hostView.expandableLabelState.isExpanded = true
        }
    }
    
    func configureNavigationBar() {
        navigationItem.title = "Host"
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        styleNavigationController()
    }
    
    func configureViews() {
        view.backgroundColor = WorkfinderColors.white
        view.addSubview(hostView)
        hostView.profileLinkTap = { association in
            self.presenter.onTapLinkedin()
        }
        let guide = view.safeAreaLayoutGuide
        hostView.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
    }
    
    public init(presenter: HostViewPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
