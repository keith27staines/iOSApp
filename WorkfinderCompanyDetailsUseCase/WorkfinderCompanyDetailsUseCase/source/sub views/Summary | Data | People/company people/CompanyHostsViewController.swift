//
//  CompanyPeopleViewController.swift
//  F4SPrototypes
//
//  Created by Keith Staines on 21/12/2018.
//  Copyright © 2018 Keith Staines. All rights reserved.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI

fileprivate let cardAspectRatio: CGFloat = 1.3

protocol CompanyPeopleViewControllerDelegate {
    func companyPeopleViewController(_ controller: CompanyHostsViewController, didSelectHost: F4SHost?)
    func companyPeopleViewController(_ controller: CompanyHostsViewController, showLinkedIn: F4SHost)
}

class CompanyHostsViewController: CompanySubViewController {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HostCell.self, forCellReuseIdentifier: "HostCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    override init(viewModel: CompanyViewModel, pageIndex: CompanyViewModel.PageIndex) {
        super.init(viewModel: viewModel, pageIndex: pageIndex)
    }

    override func viewDidLoad() {
        view.addSubview(tableView)
        tableView.fillSuperview(padding: UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4))
        refresh()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func refresh() {
        let index = viewModel.selectedHostIndex
        viewModel.selectedHostIndex = nil
        tableView.reloadData()
        viewModel.selectedHostIndex = index
    }
}

extension CompanyHostsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.hosts.count
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HostCell") as! HostCell
        let host = viewModel.hosts[indexPath.row]
        cell.configureWithHost(host, profileLinkTap: profileLinkTap)
        return cell
    }
    
    func profileLinkTap(host: F4SHost) {
        viewModel.didTapLinkedIn(for: host)
    }
}

class HostCell: UITableViewCell {
    
    func configureWithHost(_ host: F4SHost, profileLinkTap: @escaping ((F4SHost) -> Void)) {
        hostView.host = host
        hostView.profileLinkTap = profileLinkTap
    }
    
    lazy var hostView: HostView = {
        return HostView()
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(hostView)
        hostView.fillSuperview(padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}










