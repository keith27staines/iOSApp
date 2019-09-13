import WorkfinderCommon
import WorkfinderUI

public class RecommendationsListViewController: UIViewController, RecommendationsListViewProtocol {
    
    weak var coordinator: RecommendationsCoordinator?
    
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
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func adjustNavigationBar() {
        let menuButton = UIBarButtonItem(image: UIImage(named: "MenuButton")?.withRenderingMode(.alwaysTemplate), style: .done, target: self, action: #selector(menuButtonTapped))
        self.navigationItem.leftBarButtonItem = menuButton
        self.navigationItem.title = NSLocalizedString("Recommendations", comment: "")
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        styleNavigationController()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        adjustNavigationBar()
        styleNavigationController()
    }
    
    @objc func menuButtonTapped() {
        coordinator?.toggleMenu()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        viewModel.viewDidAppear()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        viewModel.viewDidDisappear()
    }
    
    public func updateFromViewModel() {
        navigationController?.tabBarItem.badgeValue = viewModel.badgeValue
        guard viewModel.isViewVisible else { return }
        tableView.reloadData()
        mainView.emptyRecommendationsLabel.text = viewModel.emptyRecomendationsListText
        mainView.emptyRecommendationsView.isHidden = viewModel.emptyRecomendationsListIsHidden
    }
    
    public func showLoadingOverlay() {
        userMessageHandler.showLoadingOverlay(self.view)
    }
    
    public func hideLoadingOverlay() {
        userMessageHandler.hideLoadingOverlay()
    }
}

extension RecommendationsListViewController : UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CompanyCell
        let companyUuid = viewModel.recommendationForIndexPath(indexPath).uuid
        let company = viewModel.companyForUuid(companyUuid)
        cell.company = company
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectIndexPath(indexPath)
    }
}
