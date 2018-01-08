//
//  RecommendationsViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 02/01/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class RecommendationsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBAction func dismissMe(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    var model: RecommendationsModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadModel()
    }
    
    func reloadModel() {
        model = RecommendationsModel()
        model.reload(completion: tableView.reloadData)
    }
}

extension RecommendationsViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recommendation = model.recommendationForIndexPath(indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        configure(cell: cell, recommendation: recommendation)
        return cell
    }
    
    func configure(cell: UITableViewCell, recommendation: Recommendation) {
        var recommendation = recommendation
        cell.textLabel?.text = ""
        cell.imageView?.image = Company.defaultLogo
        cell.detailTextLabel?.text = ""
        guard let company = recommendation.company else {
            return
        }
        cell.textLabel?.text = company.name
        company.getLogo(defaultLogo: Company.defaultLogo) { (image) in
            DispatchQueue.main.async {
                cell.imageView?.image = image
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var recommendation = model.recommendationForIndexPath(indexPath)
        guard let company = recommendation.company else {
            return
        }
        CustomNavigationHelper.sharedInstance.showCompanyDetailsPopover(parentCtrl: self, company: company)
    }
}
