//
//  AccountViewController.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 08/04/2021.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI

class AccountViewController: UIViewController {

    lazy var messageHandler: UserMessageHandler = UserMessageHandler(presenter: self)
    let presenter: AccountPresenter
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .grouped)
        table.dataSource = presenter
        table.delegate = presenter
        table.register(AMPHeaderCell.self, forCellReuseIdentifier: AMPHeaderCell.reuseIdentifier)
        table.register(AMPAccountSectionCell.self, forCellReuseIdentifier: AMPAccountSectionCell.reuseIdentifier)
        table.register(AMPLinksCell.self, forCellReuseIdentifier: AMPLinksCell.reuseIdentifier)
        table.estimatedRowHeight = UITableView.automaticDimension
        table.rowHeight = UITableView.automaticDimension
        table.tableFooterView = footer
        return table
    }()
    
    lazy var footer: UIView = {
        let view = UIView()
        let label = UILabel()
        view.addSubview(label)
        label.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 0))
        label.text = "Member since 09 April 2020 • v3.4.0 (0)"
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor.init(white: 0, alpha: 0.4)
        label.frame = CGRect(x: 0, y: 0, width: 0, height: 44)
        return view
    }()
    
    override func viewDidLoad() {
        configureViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        configureNavigationBar()
        reloadData()
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func configureNavigationBar() {
        navigationItem.title = "Account"
        styleNavigationController()
    }
    
    func configureViews() {
        let guide = view.safeAreaLayoutGuide
        view.addSubview(tableView)
        tableView.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor)
    }
    
    init(coordinator: AccountCoordinator) {
        presenter = AccountPresenter(coordinator: coordinator)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


