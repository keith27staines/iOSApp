
import UIKit
import WorkfinderUI

class RecommendationsViewController: UIViewController {
    
    lazy var messageHandler = UserMessageHandler(presenter: self)
    let presenter: RecommendationsPresenter
    
    lazy var tableview: UITableView = {
        let view = UITableView()
        view.dataSource = self
        view.register(UITableViewCell.self, forCellReuseIdentifier: "recommendation")
        return view
    }()
    
    init(presenter: RecommendationsPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        presenter.onViewDidLoad(view: self)
        loadData()
    }
    
    func configureViews() {
        let guide = view.safeAreaLayoutGuide
        view.addSubview(tableview)
        tableview.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
    }
    
    func refresh() {
        
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
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
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
