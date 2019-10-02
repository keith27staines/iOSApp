//
//  PopupCompanyListViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 14/11/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI

class PopupCompanyListViewController: UIViewController {
    let screenName = ScreenName.companyClusterList
    var log: F4SAnalyticsAndDebugging!
    
    public func setCompanies(_ companies: [Company]) {
        self.companies = companies.sorted(by: { (company1, company2) -> Bool in
            return company1.rating >= company2.rating
        })
    }
    
    var didSelectCompany: ((Company) -> Void)?
    
    private var companies: [Company]!

    @IBOutlet var tableView: UITableView!
    @IBOutlet var doneButton: UIButton!
    
    override func viewDidLoad() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        log.screen(screenName)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Table view data source
extension PopupCompanyListViewController : UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return companies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "companyInfoView", for: indexPath) as! CompanyInfoTableViewCell
        let company = companies[indexPath.row]
        cell.company = company
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showCompanyInfo(indexPath: indexPath)
    }
    
    func showCompanyInfo(indexPath: IndexPath) {
        let company = companies[indexPath.row]
        didSelectCompany?(company)
    }
}
