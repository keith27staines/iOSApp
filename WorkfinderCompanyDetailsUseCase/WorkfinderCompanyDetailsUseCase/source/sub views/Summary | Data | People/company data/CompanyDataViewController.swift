//
//  CompanyDataViewController.swift
//  F4SPrototypes
//
//  Created by Keith Staines on 21/12/2018.
//  Copyright © 2018 Keith Staines. All rights reserved.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI

class CompanyDataViewController: CompanySubViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        configureViews()
        refresh()
    }
    
    override func loadView() {
        view = UIView()
    }
    
    func configureViews() {
        view.addSubview(duedilButton)
        view.addSubview(linkedinButton)
        view.addSubview(revenueLabel)
        view.addSubview(growthLabel)
        view.addSubview(employeesLabel)

        revenueLabel.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 12, left: 8, bottom: 0, right: 0))
        growthLabel.anchor(top: revenueLabel.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 0))
        employeesLabel.anchor(top: growthLabel.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 0))
        duedilButton.anchor(top: employeesLabel.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 12, left: 8, bottom: 0, right: 0))
        linkedinButton.anchor(top: duedilButton.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 12, left: 8, bottom: 0, right: 0))
    }
    
    override func refresh() {
        duedilButton.isHidden = company.duedilIsHiden
        linkedinButton.isHidden = company.linkedinIsHidden
        revenueLabel.text = company.revenueString
        revenueLabel.isHidden = company.revenueIsHidden
        growthLabel.text = company.growthString
        growthLabel.isHidden = company.growthIsHidden
        employeesLabel.text = company.employeesString
        employeesLabel.isHidden = company.employeesIsHidden
    }
    
    let revenueLabel: UILabel = { return UILabel() }()
    let growthLabel: UILabel = { return UILabel() }()
    let employeesLabel: UILabel = { return UILabel() }()
    
    var company: CompanyViewData { return viewModel.companyViewData }
    
    var duedilButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.isHidden = true
        let image = UIImage(named: "ui-duedil-icon")
        button.setImage(image, for: .normal)
        button.setTitle("See more on Duedil", for: .normal)
        button.addTarget(self, action: #selector(handleDuedilTapped), for: .touchUpInside)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        return button
    }()
    
    var linkedinButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.isHidden = true
        button.setImage(#imageLiteral(resourceName: "ui-linkedin-icon"), for: .normal)
        button.setTitle("See more on LinkedIn", for: .normal)
        button.addTarget(self, action: #selector(handleLinkedinTapped), for: .touchUpInside)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        return button
    }()
    
    @objc func handleDuedilTapped() {
        viewModel.didTapDuedil(for: company)
    }
    @objc func handleLinkedinTapped() {
        viewModel.didTapLinkedIn(for: company)
    }
}
