//
//  WFViewController.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 10/04/2021.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI

class WFViewController: UIViewController {
    lazy var messageHandler: UserMessageHandler = UserMessageHandler(presenter: self)
    let presenter: BaseAccountPresenter
    var coordinator: AccountCoordinator?
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .grouped)
        table.estimatedRowHeight = UITableView.automaticDimension
        table.rowHeight = UITableView.automaticDimension
        return table
    }()
    
    func registerTableCells() {}
    
    override func viewDidLoad() {
        configureViews()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPresenter), name: .wfDidLoginCandidate, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        styleNavigationController()
    }
    
    func configureViews() {
        let guide = view.safeAreaLayoutGuide
        view.addSubview(tableView)
        tableView.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor)
        registerTableCells()
        tableView.dataSource = presenter
        tableView.delegate = presenter
    }
    
    init(coordinator: AccountCoordinator, presenter: BaseAccountPresenter) {
        self.coordinator = coordinator
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
