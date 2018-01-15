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
    
    var emptyRecomendationsListText: String? = nil
    
    var model: RecommendationsModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadModel()
    }
    
    func reloadModel() {
        model = RecommendationsModel()
        model.reload() { [weak self] in
            self?.tableView.reloadData()
            self?.configureNoRecomendationsOverlay()
        }
    }
    
    lazy var emptyRecommendationsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        view.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: tableView.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: tableView.rightAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
        view.backgroundColor = UIColor.white
        let label = emptyRecommendationsLabel
        view.addSubview(label)
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        return view
    }()
    
    lazy var emptyRecommendationsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.lightGray
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    func configureNoRecomendationsOverlay() {
        let defaultText = "No recommendations for you yet"
        if !model.recommendationsExist {
            emptyRecommendationsLabel.text = emptyRecomendationsListText ?? defaultText
            emptyRecommendationsView.isHidden = false
        } else {
            emptyRecommendationsLabel.isHidden = true
        }
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
