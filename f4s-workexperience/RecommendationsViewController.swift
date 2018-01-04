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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        //cell.imageView?.image = recommendation.image
        cell.textLabel?.text = recommendation.companyName
        cell.detailTextLabel?.text = ""
        //cell.detailTextLabel?.text = recommendation.explanation
    }
}
