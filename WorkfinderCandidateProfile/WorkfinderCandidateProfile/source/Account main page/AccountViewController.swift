//
//  AccountViewController.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 08/04/2021.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI

class AccountViewController: WFViewController {

    var accountPresenter: AccountPresenter { presenter as! AccountPresenter }
    
    override func registerTableCells() {
        tableView.register(AMPHeaderCell.self, forCellReuseIdentifier: AMPHeaderCell.reuseIdentifier)
        tableView.register(AMPAccountSectionCell.self, forCellReuseIdentifier: AMPAccountSectionCell.reuseIdentifier)
        tableView.register(AMPLinksCell.self, forCellReuseIdentifier: AMPLinksCell.reuseIdentifier)
    }
    
    lazy var footer: UIView = {
        let view = UIView()
        view.addSubview(footerLabel)
        footerLabel.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 0, left: 26, bottom: 0, right: 0))
        view.frame = CGRect(x: 0, y: 0, width: 0, height: 44)
        return view
    }()
    
    lazy var footerLabel: UILabel = {
        let label = UILabel()
        view.addSubview(label)
        label.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 0))
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor.init(white: 0, alpha: 0.4)
        return label
    }()
    
    override func reloadData() {
        super.reloadData()
        footerLabel.text = accountPresenter.footerLabelText
    }
    
    override func configureViews() {
        super.configureViews()
        tableView.tableFooterView = footer
    }
    
    override func configureNavigationBar() {
        super.configureNavigationBar()
        navigationItem.title = "Account"
    }
    
}


