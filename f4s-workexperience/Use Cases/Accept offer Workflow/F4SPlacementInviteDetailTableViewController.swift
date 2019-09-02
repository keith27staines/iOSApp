//
//  F4SPlacementInviteDetailTableViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 19/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit
import WorkfinderCommon
import WorkfinderAcceptUseCase

class F4SPlacementInviteDetailTableViewController: UITableViewController {

    let model = F4SPlacementInviteModel()
    var accept: AcceptOfferContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return model.numberOfSections() + 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < model.numberOfSections() {
            // Most sections contain data as described by the model
            return model.numberOfRows(section)
        } else {
            // The very last section doesn't contain data from the model, it contains buttons to allow the user to accept or decline
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let detail = model.inviteDetailsForIndexPath(indexPath)
        if indexPath.section < model.numberOfSections() {
            let cell = tableView.dequeueReusableCell(withIdentifier: "detail", for: indexPath)
            cell.imageView?.image = detail.icon
            cell.textLabel?.text = detail.title
            cell.detailTextLabel?.text = detail.lines?[0] ?? ""
            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: "buttons")!
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = model.headerForSection(section)
        let cell = tableView.dequeueReusableCell(withIdentifier: "header")!
        cell.textLabel?.text = header.title
        return cell
    }
    @IBAction func proceedButtonTapped(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let enterVoucherViewController = segue.destination as? AddVoucherViewController {
            enterVoucherViewController.accept = accept
            return
        }
    }

}
