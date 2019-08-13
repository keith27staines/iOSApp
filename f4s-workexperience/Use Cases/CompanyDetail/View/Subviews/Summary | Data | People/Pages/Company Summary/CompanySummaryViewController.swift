//
//  CompanyDescriptionViewController.swift
//  F4SPrototypes
//
//  Created by Keith Staines on 21/12/2018.
//  Copyright © 2018 Keith Staines. All rights reserved.
//

import UIKit
import WorkfinderUI

class CompanySummaryViewController: CompanySubViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        refresh()
    }
    
    func configureViews() {
        addSubControllers()
        view.addSubview(industryLabel)
        view.addSubview(ratingView)
        view.addSubview(addressView)
        view.addSubview(distanceFromYouView)
        view.addSubview(descriptionView)
        industryLabel.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor)
        ratingView.anchor(top: industryLabel.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0), size: CGSize(width: 0, height: 12))
        ratingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        addressView.anchor(top: ratingView.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0))
        distanceFromYouView.anchor(top: addressView.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0))
        descriptionView.anchor(top: distanceFromYouView.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0))

        documentsView.anchor(top: descriptionView.bottomAnchor, leading: descriptionView.leadingAnchor, bottom: view.bottomAnchor, trailing: descriptionView.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0), size: CGSize(width: 0, height: 100))
    }
    
    var documentsView: UIView!
    
    func addSubControllers() {
        let documentsModel = F4SCompanyDocumentsModel(companyUuid: viewModel.company.uuid)
        let vc = CompanyDocumentsViewController(documentsModel: documentsModel)
        documentsView = vc.view
        view.addSubview(documentsView)
        addChild(vc)
        vc.didMove(toParent: self)
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.white
    }
    
    var companyViewData: CompanyViewData { return viewModel.companyViewData }
    
    override func refresh() {
        ratingView.rating = companyViewData.starRating ?? 0
        ratingView.isHidden = companyViewData.starRatingIsHidden
        industryLabel.text = companyViewData.industry
        industryLabel.isHidden = companyViewData.industryIsHidden
        descriptionView.text = companyViewData.description
        if let postcode = companyViewData.postcode {
            addressView.text = "Location: \(postcode)"
            addressView.isHidden = false
        } else {
            addressView.isHidden = true
        }
        distanceFromYouView.isHidden = viewModel.distanceFromUserToCompany == nil
        distanceFromYouView.text = viewModel.distanceFromUserToCompany
    }
    
    var industryLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12)
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()
    
    var ratingView: StarRatingView = {
        let ratingView = StarRatingView()
        return ratingView
    }()
    
    lazy var descriptionView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        textView.isEditable = false
        textView.text = ""
        return textView
    }()
    
    lazy var addressView: UILabel = {
        let label = UILabel()
        label.text = "Can't load address"
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12)
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.vertical)
        return label
    }()
    
    lazy var distanceFromYouView: UILabel = {
        let label = UILabel()
        label.text = "Distance from you: unknown"
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.vertical)
        return label
    }()
}
