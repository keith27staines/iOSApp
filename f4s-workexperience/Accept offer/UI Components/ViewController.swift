//
//  ViewController.swift
//  ViewDesign
//
//  Created by Keith Staines on 21/07/2018.
//  Copyright © 2018 Keith Staines. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var headerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var pageHeader: F4SCompanyHeaderViewWithLogo!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        tableView.delegate = self
        tableView.dataSource = self
        pageHeader.icon = UIImage(named: "testIcon")
        pageHeader.fillColor = UIColor.blue
    }
    
    let initialHeaderHeight: CGFloat = 100

}

extension ViewController : UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let headerHeight = headerHeight else { return }
        let constant = max(initialHeaderHeight - scrollView.contentOffset.y/5.0,40)
        headerHeight.constant = constant
    }
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = "Row \(indexPath.row)"
        return cell
        
    }
    
    
    
}

