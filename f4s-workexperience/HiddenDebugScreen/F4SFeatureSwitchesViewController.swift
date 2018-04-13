//
//  F4SFeatureSwitchesViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 08/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class F4SFeatureSwitchesViewController: UITableViewController {
    
    var featuresModel: F4SFeatureSwitchModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        let service = F4SFeatureSwitchService()
        featuresModel = F4SFeatureSwitchModel(delegate: self, service: service)
    }
    
    @IBAction func reset(_ sender: Any) {
        
    }
    
}

extension F4SFeatureSwitchesViewController: F4SFeatureSwitchModelDelegate {
    func featureSwitchModelCompletedFetchFromServer() {
        tableView.reloadData()
    }
}

// MARK: - Table view data source
extension F4SFeatureSwitchesViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return featuresModel.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return featuresModel.numberOfFeaturesInSection(section: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.cell(for: indexPath)
        configure(cell: cell, for: indexPath)
        return cell
     }
    
    func cell(for indexPath: IndexPath) -> F4SFeatureSwitchTableViewCell {
        let identifier = self.identifier(for: indexPath.section)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! F4SFeatureSwitchTableViewCell
        return cell
    }
    
    func configure(cell: F4SFeatureSwitchTableViewCell ,for indexPath: IndexPath) {
        cell.feature = featuresModel.feature(indexPath: indexPath)
    }
    
    func identifier(for section: Int) -> String {
        switch section {
        default:
            return "cell"
        }
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
