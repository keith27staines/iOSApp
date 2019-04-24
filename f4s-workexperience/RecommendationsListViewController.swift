import WorkfinderCommon


class RecommendationsListViewController: UIViewController, RecommendationsListViewProtocol {
    
    var emptyRecomendationsListText: String? = nil
    var selectCompany: Company?
    
    var viewModel: RecommendationsViewModelProtocol!
    let userMessageHandler = UserMessageHandler()
    
    @IBOutlet weak var mainView: RecommendationsListMainView!
    var tableView: UITableView { return mainView.tableView }
    
    func inject(viewModel: RecommendationsViewModelProtocol) {
        self.viewModel = viewModel
        viewModel.startPolling()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        styleNavigationController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.viewDidAppear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        viewModel.viewDidDisappear()
    }
    
    func updateFromViewModel() {
        navigationController?.tabBarItem.badgeValue = viewModel.badgeValue
        guard viewModel.isViewVisible else { return }
        tableView.reloadData()
        mainView.emptyRecommendationsLabel.text = viewModel.emptyRecomendationsListText
        mainView.emptyRecommendationsView.isHidden = viewModel.emptyRecomendationsListIsHidden
    }
    
    func showLoadingOverlay() {
        userMessageHandler.showLoadingOverlay(self.view)
    }
    
    func hideLoadingOverlay() {
        userMessageHandler.hideLoadingOverlay()
    }
}

extension RecommendationsListViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CompanyCell
        let companyUuid = viewModel.recommendationForIndexPath(indexPath).uuid
        cell.configureWithCompanyUuid(companyUuid)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectIndexPath(indexPath)
    }
}
