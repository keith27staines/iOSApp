//
//  YourDetailsViewController.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 10/04/2021.
//

import UIKit
import WorkfinderCommon

class YourDetailsViewController:  WFViewController {
    
    let presenter: YourDetailsPresenter
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .grouped)
        table.dataSource = presenter
        table.delegate = presenter
        table.estimatedRowHeight = UITableView.automaticDimension
        table.rowHeight = UITableView.automaticDimension
        return table
    }()
    
    func registerTableCells() {
        tableView.register(AMPHeaderCell.self, forCellReuseIdentifier: AMPHeaderCell.reuseIdentifier)
        tableView.register(AMPAccountSectionCell.self, forCellReuseIdentifier: AMPAccountSectionCell.reuseIdentifier)
        tableView.register(AMPLinksCell.self, forCellReuseIdentifier: AMPLinksCell.reuseIdentifier)
    }
    
    override func viewDidLoad() {
        configureViews()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPresenter), name: .wfDidLoginCandidate, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        configureNavigationBar()
        reloadPresenter()
    }
    
    @objc func reloadPresenter() {
        reloadData()
        presenter.reloadPresenter() { [weak self] (optionalError) in
            guard let self = self else { return }
            self.messageHandler.displayOptionalErrorIfNotNil(optionalError) {
                self.reloadPresenter()
            }
            self.reloadData()
        }
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func configureNavigationBar() {
        navigationItem.title = "Your Details"
        styleNavigationController()
    }
    
    func configureViews() {
        let guide = view.safeAreaLayoutGuide
        view.addSubview(tableView)
        tableView.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor)
        registerTableCells()
    }
    
    init(coordinator: AccountCoordinator, presenter: YourDetailsPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}
