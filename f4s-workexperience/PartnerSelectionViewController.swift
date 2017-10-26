//
//  PartnerSelectionViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 26/10/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import UIKit

class PartnerSelectionViewController: UIViewController {

    lazy var partnersModel: PartnersModel = {
       return PartnersModel()
    }()
}

extension PartnerSelectionViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return partnersModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return partnersModel.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let view = tableView.dequeueReusableCell(withIdentifier: "partnerCell")!
        let partner = partnersModel.partnerForIndexPath(indexPath)
        view.textLabel?.text = partner.name
        return view
    }
    
}
